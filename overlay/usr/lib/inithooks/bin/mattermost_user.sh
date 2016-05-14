#!/bin/bash -ex
platform="/opt/mattermost/bin"

username=""$1"
email="$2"

cd $platform && ./platform -create_user -email="$email" -password="$password" -username="$username"

cd $platform && ./platform -assign_role -email="$email" role="system_admin"
