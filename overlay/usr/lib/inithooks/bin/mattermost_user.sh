#!/bin/bash
platform="/opt/mattermost/bin"

username="$1"
password="$2"
email="$3"
teamname="$4"

if [ -e "$platform/platform" ]; then

	cat <<EOF
$platform/platform -create_user -team_name="$teamname" -email="$email" -password="$password" -username="username"
$platform/platform -assign_role -email="$email" -role="system_admin")
EOF
exit 0
else:
	exit 1
fi
