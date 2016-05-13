#!/usr/bin/python
"""Set Mattermost admin user, password, email, and team name
Option:
    --pass=     unless provided, will ask interactively
    --email=    unless provided, will ask interactively
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

def usage(s=None):
    if s:
        print >> sys.stderr, "Error:", s
    print >> sys.stderr, "Syntax: %s [options]" % sys.argv[0]
    print >> sys.stderr, __doc__
    sys.exit(1)

def main():
    try:
        opts, args = getopt.gnu_getopt(sys.argv[1:], "h",
                                       ['help', 'pass=', 'email=', 'username='])
    except getopt.GetoptError, e:
        usage(e)

    password = ""
    email = ""
    username = ""

    platform = "/opt/mattermost/bin/platform"

    for opt, val in opts:
        if opt in ('-h', '--help'):
            usage()
        elif opt == '--pass':
            password = val
        elif opt == '--email':
            email = val
        elif opt == '--username':
            username = val


    if not username:
        d=Dialog('Turnkey Linux - First boot configuration')
        username = d.get_text(
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

    def commit():
        call(["platform"+ "-create_user" + "-teamname=\'default\'" + "-email=\'email\'" + "password=\'password\'"])
        call(["platform" + "-assign_role" + "-email=\'email\'" + "role='sysadmin'"])

    commit()

    #inithooks_cache.write('APP_EMAIL', email)


"""
    sitesalt = ""
    for line in file("/var/www/mahara/config.php", "r").readlines():
        m = re.match(r"\$cfg->passwordsaltmain = '(.*)';", line.strip())
        if m:
            sitesalt = m.groups()[0]

    salt = hashlib.sha1(str(random.random())).hexdigest()[:8]
    fullsalt = hashlib.md5(sitesalt + salt).hexdigest()[:16]

    alg = "$6$"
    hash = hashlib.sha1(salt + password).hexdigest()
    hash = crypt.crypt(hash, alg + fullsalt)
    hash = alg + hash[len(alg)+len(fullsalt):]

    p = PostgreSQL(database='mahara')
    p.execute('UPDATE usr SET salt=\'%s\' WHERE username=\'admin\';' % salt)
    p.execute('UPDATE usr SET password=\'%s\' WHERE username=\'admin\';' % hash)
    p.execute('UPDATE usr SET passwordchange=0 WHERE username=\'admin\';')
    p.execute('UPDATE usr SET email=\'%s\' WHERE username=\'admin\';' % email)
    p.execute('UPDATE artefact SET title=\'%s\' WHERE artefacttype=\'email\';' % email)
    p.execute('UPDATE artefact_internal_profile_email SET email=\'%s\' WHERE owner=1;' % email)
"""

if __name__ == "__main__":
    main()

Status API Training Shop Blog About
