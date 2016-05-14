#!/usr/bin/python
"""Set Mattermost admin user, password, email, and team name
Option:
    --pass=     unless provided, will ask interactively
    --email=    unless provided, will ask interactively
    --username= unless provided, will ask interactively
    --teamname= unless provided, will ask interactively
"""

import re
import sys
import getopt
import inithooks_cache

import crypt
import random
import hashlib

from dialog_wrapper import Dialog
from pgsqlconf import PostgreSQL
from subprocess import call
import os

def usage(s=None):
    if s:
        print >> sys.stderr, "Error:", s
    print >> sys.stderr, "Syntax: %s [options]" % sys.argv[0]
    print >> sys.stderr, __doc__
    sys.exit(1)

def main():
    try:
        opts, args = getopt.gnu_getopt(sys.argv[1:], "h",
                                       ['help', 'pass=', 'email=', 'username=','teamname='])
    except getopt.GetoptError, e:
        usage(e)

    password = ""
    email = ""
    username = ""
    teamname = ""

    for opt, val in opts:
        if opt in ('-h', '--help'):
            usage()
        elif opt == '--pass':
            password = val
        elif opt == '--email':
            email = val
        elif opt == '--username':
            username = val
        elif opt == '--teamname':
            teamname = val

    if not username:
        d=Dialog('Turnkey Linux - First boot configuration')
        username = d.get_input(
            "Mattermost Admin User Name",
            "Enter a username for the Mattermost administrator.")

    if not password:
        d = Dialog('TurnKey Linux - First boot configuration')
        password = d.get_password(
            "Mattermost Admin Password",
            "Enter new password for the Mattermost administrator's  account.")

    if not email:
        if 'd' not in locals():
            d = Dialog('TurnKey Linux - First boot configuration')

        email = d.get_email(
            "Mattermost Administrator's Email",
            "Enter email address for the Mattermost 'admin' user.",
            "admin@example.com")
    if not teamname:
        d = Dialog('TurnKey Linux - First boot configuration')
        teamname = d.get_input(
            "Initial team name",
            "Enter a name for the first Mattermost team"
        )
    def commit():
        os("cd /opt/mattermost/bin/ && ./platform -create_user -team_name='teamname'-email='email' password='password' -username='username'")
        os("cd /opt/mattermost/bin && ./platform -assign_role -email='email' role='sysadmin'")


    commit()

    #inithooks_cache.write('APP_EMAIL', email)





if __name__ == "__main__":
    main()

#Status API Training Shop Blog About
