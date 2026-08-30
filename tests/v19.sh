#!/bin/bash
set -euo pipefail

result=${TKL_TEST_RESULT:?}
password=${TKL_TEST_APP_PASS:?}
api=http://127.0.0.1:8065/api/v4
work=/run/tkl-v19-tests/mattermost
config=/opt/mattermost/config/config.json
mmctl=(runuser -u mattermost -- /opt/mattermost/bin/mmctl --local)
mkdir -p "$work"
updated_secret=
cleanup() {
    rm -f "$work/config-before.json"
    unset updated_secret
}
trap cleanup EXIT

for service in mattermost.service nginx.service postgresql.service; do
    systemctl --quiet is-active "$service"
done
grep -Fq '[20regen-mattermost-secrets] successfully completed' /var/log/inithooks.log
! grep -Fq '[20regen-mattermost-secrets] failed' /var/log/inithooks.log
curl -fsS "$api/system/ping" >"$work/ping.json"
grep -Fq '"status":"OK"' "$work/ping.json"
curl -kfsS --resolve www.example.com:443:127.0.0.1 \
    https://www.example.com/api/v4/system/ping >/dev/null

/opt/mattermost/bin/mattermost version >"$work/version.txt"
version=$(sed -n 's/^Version:[[:space:]]*//p' "$work/version.txt" | head -1)
test "$version" = 11.8.3

# This appliance intentionally uses Mattermost's default file-backed store. A
# Configurations table exists only after an explicit MM_CONFIG database
# migration, which this appliance does not perform.
! systemctl show mattermost.service -p Environment --value | \
    grep -Eq '(^|[[:space:]])MM_CONFIG='
test "$(runuser -u postgres -- psql -XqAt -d mattermost \
    -c "SELECT to_regclass('public.configurations') IS NULL")" = t

"${mmctl[@]}" config get ServiceSettings.SiteURL >"$work/site-url-before.json"
cp "$config" "$work/config-before.json"
chmod 0600 "$work/config-before.json"
python3 - "$work/config-before.json" "$work/site-url-before.json" <<'PY'
import json
import re
import sys
from pathlib import Path

config = json.loads(Path(sys.argv[1]).read_text())
active_site_url = json.loads(Path(sys.argv[2]).read_text())
keys = (
    ('SqlSettings', 'AtRestEncryptKey'),
    ('FileSettings', 'PublicLinkSalt'),
)
values = [config[section][key] for section, key in keys]
assert all(re.fullmatch(r'[0-9a-f]{32}', value) for value in values)
assert len(set(values)) == len(values)
assert config['ServiceSettings']['SiteURL'] == 'https://localhost'
assert active_site_url == 'https://localhost'
PY

runuser -u mattermost -- test ! -w /opt/mattermost/bin/mattermost
runuser -u mattermost -- test ! -w /opt/mattermost/config
test "$(stat -c '%U:%G %a' "$config")" = 'mattermost:mattermost 640'
runuser -u mattermost -- touch /opt/mattermost/data/.tkl-v19-write-test
runuser -u mattermost -- rm /opt/mattermost/data/.tkl-v19-write-test

# Exercise the supported v11 local configuration API, including a secret, and
# prove that the file-backed store records the update without exposing either
# value in the test output.
updated_site_url=https://mattermost.qa.invalid
updated_secret=$(openssl rand -hex 16)
"${mmctl[@]}" config set ServiceSettings.SiteURL "$updated_site_url" \
    >"$work/site-url-set.txt"
"${mmctl[@]}" config set FileSettings.PublicLinkSalt "$updated_secret" \
    >"$work/public-link-salt-set.txt"
"${mmctl[@]}" config get ServiceSettings.SiteURL >"$work/site-url-after-set.json"
python3 - "$work/config-before.json" "$config" \
    "$work/site-url-after-set.json" 3<<<"$updated_secret" <<'PY'
import json
import os
import sys
from pathlib import Path

before = json.loads(Path(sys.argv[1]).read_text())
after = json.loads(Path(sys.argv[2]).read_text())
active_site_url = json.loads(Path(sys.argv[3]).read_text())
expected_secret = os.fdopen(3).read().rstrip('\n')
assert after['ServiceSettings']['SiteURL'] == 'https://mattermost.qa.invalid'
assert active_site_url == 'https://mattermost.qa.invalid'
assert after['FileSettings']['PublicLinkSalt'] == expected_secret
assert after['FileSettings']['PublicLinkSalt'] != before['FileSettings']['PublicLinkSalt']
PY
test "$(stat -c '%U:%G %a' "$config")" = 'mattermost:mattermost 640'

token=$(printf '%s' "$password" | python3 -c '
import json
import sys
import urllib.request

request = urllib.request.Request(
    sys.argv[1],
    data=json.dumps({"login_id": "admin", "password": sys.stdin.read()}).encode(),
    headers={"Content-Type": "application/json"},
)
with urllib.request.urlopen(request) as response:
    body = response.read()
    open(sys.argv[2], "wb").write(body)
    print(response.headers["Token"])
' "$api/users/login" "$work/login.json")
test -n "$token"

curl -fsS -H "Authorization: Bearer $token" -H 'Content-Type: application/json' \
    --data '{"name":"qa-team","display_name":"QA Team","type":"O"}' \
    "$api/teams" >"$work/team.json"
team_id=$(python3 -c 'import json; print(json.load(open("'$work'/team.json"))["id"])')
curl -fsS -H "Authorization: Bearer $token" -H 'Content-Type: application/json' \
    --data "{\"team_id\":\"$team_id\",\"name\":\"qa-channel\",\"display_name\":\"QA Channel\",\"type\":\"O\"}" \
    "$api/channels" >"$work/channel.json"
channel_id=$(python3 -c 'import json; print(json.load(open("'$work'/channel.json"))["id"])')
curl -fsS -H "Authorization: Bearer $token" -H 'Content-Type: application/json' \
    --data "{\"channel_id\":\"$channel_id\",\"message\":\"qa-persistence-marker\"}" \
    "$api/posts" >"$work/post.json"
post_id=$(python3 -c 'import json; print(json.load(open("'$work'/post.json"))["id"])')

systemctl restart mattermost.service
for _ in $(seq 1 30); do
    curl -fsS "$api/system/ping" >/dev/null 2>&1 && break
    sleep 1
done
curl -fsS -H "Authorization: Bearer $token" "$api/posts/$post_id" >"$work/post-after-restart.json"
grep -Fq 'qa-persistence-marker' "$work/post-after-restart.json"

"${mmctl[@]}" config get ServiceSettings.SiteURL >"$work/site-url-after-restart.json"
python3 - "$config" "$work/site-url-after-restart.json" \
    3<<<"$updated_secret" <<'PY'
import json
import os
import sys
from pathlib import Path

config = json.loads(Path(sys.argv[1]).read_text())
active_site_url = json.loads(Path(sys.argv[2]).read_text())
expected_secret = os.fdopen(3).read().rstrip('\n')
assert config['ServiceSettings']['SiteURL'] == 'https://mattermost.qa.invalid'
assert active_site_url == 'https://mattermost.qa.invalid'
assert config['FileSettings']['PublicLinkSalt'] == expected_secret
PY
test "$(stat -c '%U:%G %a' "$config")" = 'mattermost:mattermost 640'

! grep -R -F -- "$password" /var/log/inithooks.log /var/log/mattermost 2>/dev/null
! grep -R -F -- "$updated_secret" /var/log/inithooks.log /var/log/mattermost 2>/dev/null

cat >"$result" <<EOF
package_source=official Mattermost Team Edition archive pinned by SHA-256
installed_version=$version
runtime_checks=services, direct and Nginx API health, file-backed v11 configuration schema boundary, supported local API Site URL and secret update persistence, admin login, team/channel/post lifecycle, restart persistence, secret uniqueness, ownership boundaries, credential log hygiene
updater_command=supervised official Mattermost upgrade procedure documented in README
updater_result=installed version unchanged during QA
updater_channel=official Mattermost Team Edition releases
integrity_evidence=release archive pinned to 5c864ac5fc83f95f94d2c04a7f40eb9248e6118d84ec916f3e6290768e488aa9
EOF
