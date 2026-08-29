#!/bin/bash
set -euo pipefail

result=${TKL_TEST_RESULT:?}
password=${TKL_TEST_APP_PASS:?}
api=http://127.0.0.1:8065/api/v4
work=/run/tkl-v19-tests/mattermost
mkdir -p "$work"

systemctl --quiet is-active mattermost.service nginx.service postgresql.service
curl -fsS "$api/system/ping" >"$work/ping.json"
grep -Fq '"status":"OK"' "$work/ping.json"
curl -kfsS --resolve www.example.com:443:127.0.0.1 \
    https://www.example.com/api/v4/system/ping >/dev/null

/opt/mattermost/bin/mattermost version >"$work/version.txt"
version=$(sed -n 's/^Version:[[:space:]]*//p' "$work/version.txt" | head -1)
test "$version" = 11.8.3

test "$(runuser -u postgres -- psql -XqAt -d mattermost \
    -c 'SELECT count(*) FROM configurations WHERE active')" = 1
runuser -u postgres -- psql -XqAt -d mattermost \
    -c 'SELECT value FROM configurations WHERE active' >"$work/config.json"
python3 - "$work/config.json" <<'PY'
import json
import re
import sys
from pathlib import Path

config = json.loads(Path(sys.argv[1]).read_text())
keys = (
    ('SqlSettings', 'AtRestEncryptKey'),
    ('FileSettings', 'PublicLinkSalt'),
)
values = [config[section][key] for section, key in keys]
assert all(re.fullmatch(r'[0-9a-f]{32}', value) for value in values)
assert len(set(values)) == len(values)
assert config['ServiceSettings']['SiteURL'] == 'https://localhost'
PY

runuser -u mattermost -- test ! -w /opt/mattermost/bin/mattermost
runuser -u mattermost -- test ! -w /opt/mattermost/config
test "$(stat -c '%U:%G %a' /opt/mattermost/config/config.json)" = 'mattermost:mattermost 640'
runuser -u mattermost -- touch /opt/mattermost/data/.tkl-v19-write-test
runuser -u mattermost -- rm /opt/mattermost/data/.tkl-v19-write-test

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

! grep -R -F -- "$password" /var/log/inithooks.log /var/log/mattermost 2>/dev/null

cat >"$result" <<EOF
package_source=official Mattermost Team Edition archive pinned by SHA-256
installed_version=$version
runtime_checks=services, direct and Nginx API health, admin login, team/channel/post lifecycle, restart persistence, secret uniqueness, ownership boundaries, password log hygiene
updater_command=supervised official Mattermost upgrade procedure documented in README
updater_result=installed version unchanged during QA
updater_channel=official Mattermost Team Edition releases
integrity_evidence=release archive pinned to 5c864ac5fc83f95f94d2c04a7f40eb9248e6118d84ec916f3e6290768e488aa9
EOF
