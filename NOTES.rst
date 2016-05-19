General Notes
================

* Tested with Mattermost 3.0.0
* Mattermost postgreSQL user is *mattermost*. The password is randomly generated. To check the password, visit /opt/mattermost/config/config.json.

Current Status
================

* Inithooks: As of May 16, both scripts in inithooks/bin work. They need a cleaning.
* mattermost service: This is the current problem being resolved (May 17). The mattermost service isn't starting on reboot.


To Do
=================

* Mattermost service is still a problem. Checked permissions. A recommended workaround: http://zwarag.com/2015/10/how-to-use-systemd-to-run-the-mattermost-chat-platform/
* TKLBAM profile
* populate .art folder
* Solve Mattermost service problem
* Solution to problem when Inithooks run anytime after the initial configuration (mattermost hooks only.)
