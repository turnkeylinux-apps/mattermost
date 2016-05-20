General Notes
================

* Tested with Mattermost 3.0.0
* Mattermost postgreSQL user is *mattermost*. The password is randomly generated. To check the password, visit /opt/mattermost/config/config.json.

Current Status
================

* Inithooks: As of May 16, both scripts in inithooks/bin work. They need a cleaning.
* mattermost service: was a problem. resolved now by asking init.d/mattermost to start after postgresql


To Do
=================

* TKLBAM profile
* populate .art folder

