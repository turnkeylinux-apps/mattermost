#!/usr/bin/python
"""Set Mattermost admin user, password, email, and team name
Option:
    --password=     unless provided, will ask interactively
    --email=    unless provided, will ask interactively
    --teamname= unless provided, will ask interactively
    --username= unless provided, will ask interactively
"""

import re
import sys
import getopt
import inithooks_cache

#import crypt
#import random
#import hashlib

from dialog_wrapper import Dialog
#from pgsqlconf import PostgreSQL
#from subprocess import call
import subprocess
import shlex

def usage(s=None):
    if s:
        print >> sys.stderr, "Error:", s
    print >> sys.stderr, "Syntax: %s [options]" % sys.argv[0]
    print >> sys.stderr, __doc__
    sys.exit(1)

def main():
    try:
        opts, args = getopt.gnu_getopt(sys.argv[1:], "h",
                                       ['help', 'password=', 'email=', 'teamname=', 'username='])
    except getopt.GetoptError, e:
        usage(e)

    password = ""
    email = ""
    teamname = ""
    username = ""

    for opt, val in opts:
        if opt in ('-h', '--help'):
            usage()
        elif opt == '--email':
            email = val
        elif opt == '--password':
            password = val
        elif opt == '--username':
            username = val
        elif opt == '--teamname':
            teamname = val

    if not username:
        d=Dialog('Turnkey Linux - First boot configuration')
        username = d.get_input(
            "Mattermost Admin User Name",
            "Enter a username for the Mattermost administrator.", "admin")


    if not email:
        if 'd' not in locals():
            d = Dialog('TurnKey Linux - First boot configuration')

        email = d.get_email(
            "Mattermost Administrator's Email",
            "Enter email address for the Mattermost 'admin' user.",
            "admin@example.com")


    if not password:
        d = Dialog('TurnKey Linux - First boot configuration')
        password = d.get_password(
            "Mattermost Admin Password",
            "Enter new password for the Mattermost administrator's  account.")

    if not teamname:
        d = Dialog('TurnKey Linux - First boot configuration')
        teamname = d.get_input(
            "Initial team name",
            "Enter a name for the first Mattermost team","Initial_Team"
        )
    #create_user = "/opt/mattermost/bin/platform -create_user -team_name=\'%s\' -email=\'%s\' -password=\'%s\' -username=\'%s\'" % (teamname, email, password, username)
    #args = shlex.split(create_user)
    #p = subprocess.Popen(args)
    #role = "/opt/mattermost/bin/platform -assign_role -email=\'%s\' role='system_admin'" % (email)
    #args = shlex.split(role)
    #p = subprocess.Popen(args)
    bashcommand = "./mattermost_user.sh %s %s %s %s" % (username, password, email, teamname)
    pieces = shlex.split(bashcommand)
    #subprocess.Popen(pieces)
    subprocess.call(pieces)



    inithooks_cache.write('APP_EMAIL', email)





if __name__ == "__main__":
    main()
