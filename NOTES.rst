General Notes
================

* Tested with Mattermost 3.0.0
* Mattermost postgreSQL user is *mattermost*. The password is randomly generated. To check the password, visit /opt/mattermost/config/config.json.

Current Status
================

* Inithooks: As of May 16, both scripts in inithooks/bin work. They need a cleaning.
* Inithooks: Currently, if inithooks run a second time, mattermost inithooks will through an error. It seems like the solution is this::

    cd /opt/mattermost/bin && platform -reset_database
    echo "YES/n"
    echo "YES/n"

* mattermost service: This is the current problem being resolved (May 17). The mattermost service isn't starting on reboot.


To Do
=================

* TKLBAM profile
* populate .art folder
* Solve Mattermost service problem
* Solution to problem when Inithooks run anytime after the initial configuration (mattermost hooks only.)
