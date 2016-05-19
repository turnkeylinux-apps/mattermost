#!/bin/bash
platform="/opt/mattermost/bin"

username="$1"
password="$2"
email="$3"
#teamname="$4"

function reset_db()
{
	cd $platform && echo -e "YES\nYES\n" | ./platform -reset_database
}

function create ()
{
	cd $platform && ./platform -create_user -email="$email" -password="$password" -username="$username"

}
function assign ()
{
	cd $platform && ./platform -assign_role -email="$email" -role="system_admin"

}

if [ -e "$platform/platform" ]; then
    reset_db $platform
	create $platform $email $password $username
	assign $platform $email
	exit 0
else:
	echo "There was a problem"
	exit 1
fi
