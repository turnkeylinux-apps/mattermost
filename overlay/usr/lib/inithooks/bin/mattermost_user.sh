#!/bin/bash -ex
platform="/opt/mattermost/bin"

username="$1"
email="$2"
password="$3"
teamname="$4"

$platform/platform -create_user -team_name="$teamname" -email="$email" -$
#$platform/platform -create_user -email="$email" -password="$password" -$
#$platform/platform -create_team -team_name="$teamname" -email="$email"
$platform/platform -assign_role -email="$email" role="system_admin")
