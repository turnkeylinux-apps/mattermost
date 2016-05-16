#!/bin/bash -ex
platform="/opt/mattermost/bin"

username="$1"
email="$2"
password="$3"
teamname="$4"

nohup (cd $platform && ./platform -create_user -email="$email" -password="$password" -username="$username" -team_name="$4")

nohup (cd $platform && ./platform -assign_role -email="$email" role="system_admin")
