Mattermost - Self-hosted Slack compatible team messaging
========================================================

`Mattermost`_ is a sleek, Slack-compatible open source service that makes it
easy to self-host team communications. It brings messaging and file
sharing into one place, accessible across PCs and mobile, with archiving
and search.  It integrates with a range of apps out-of-the-box and is
extendable so you can build custom functionality on top of the Golang /
React core.

This appliance includes all the standard features in `TurnKey Core`_,
and on top of that:

- Mattermost configurations:

    - Mattermost installed from upstream source code to /opt/mattermost

      **Security note**: Updates to Mattermost may require supervision so
      they **ARE NOT** configured to install automatically. See below for
      updating Mattermost.

    - Includes Nginx (webserver); pre-configured to proxy Mattermost.
    - Pre-configured to use PostgreSQL (recommended for production).

- SSL support out of the box.
- `Adminer`_ administration frontend for PostgreSQL (listening on
  port 12322 - uses SSL).
- Postfix MTA (bound to localhost) to allow sending of email (e.g.,
  password recovery).
- Webmin modules for configuring Postfix, PostgreSQL.

Supervised Manual Mattermost Update
-----------------------------------

**Note:** Check the Mattermost docs to ensure that upgrading your 
current version to the latest is supported. Always ensure that 
you have a tested backup before proceeding with software updates.

See the Official `Mattermost docs`_ for instructions on how to update.

Mattermost does not have a security only newsletter so we recommend that 
you subcribe to the `Mattermost Newsletter`_ to keep up to date.


Credentials *(passwords set at first boot)*
-------------------------------------------

-  Webmin, SSH: username **root**
-  PostgreSQL, Adminer: username **postgres**

	
.. _Mattermost: https://www.mattermost.org/
.. _TurnKey Core: https://www.turnkeylinux.org/core
.. _Adminer: https://adminer.org/
.. _Mattermost docs: https://docs.mattermost.com/administration/upgrade.html
.. _Mattermost Newsletter: https://mattermost.us11.list-manage.com/subscribe?u=6cdba22349ae374e188e7ab8e&id=2add1c8034

