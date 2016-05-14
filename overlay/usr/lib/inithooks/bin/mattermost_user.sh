#!/bin/bash -ex
platform="/opt/mattermost/bin"

cd $platform && ./platform -create_user -email="admin@example.com" -password="admin" -username="admin"

cd $platform && ./platform -assign_role -email="admin@example.com" role="system_admin"
