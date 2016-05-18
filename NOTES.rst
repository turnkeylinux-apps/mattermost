General Notes
================

* Tested with Mattermost 3.0.0
* Mattemost postgreSQL user is *mattermost*. The password is randomly generated. To check the password, visit /opt/mattermost/config/config.json.

Current Status
================

* Inithooks: As of May 16, both scripts in inithooks/bin work. They need a cleaning.
* mattermost service: This is the current problem being resolved (May 17). The mattermost service isn't starting on reboot.
* php-fastcgi service: Same status as mattermost service above.

To Do
=================

* TKLBAM profile
* populate .art folder
* out of box email configuration
