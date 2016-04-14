Mattermost - open source, self-hosted Slack-alternative
=======================================================

`Mattermost`_ is an alternative to proprietary SaaS messaging and
brings all your team communication into one place, making it 
searchable and accessible anywhere. 

This appliance includes all the standard features in `TurnKey Core`_,
and on top of that:

- Web Control Panel
- `Adminer`_ administration frontend for PostgreSQL (listening on
  port 12322 - uses SSL).
- Webmin modules for configuring PostgreSQL.


Credentials *(passwords set at first boot)*
-------------------------------------------

-  Webmin, SSH: username **root**
-  PostgreSQL, Adminer: username **postgres**

	
.. _Mattermost: https://www.mattermost.org/
.. _TurnKey Core: https://www.turnkeylinux.org/core
.. _Adminer: http://adminer.org/
