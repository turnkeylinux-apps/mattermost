Mattermost - open source, self-hosted Slack-alternative
=======================================================

`Mattermost`_ is an alternative to proprietary SaaS messaging and
brings all your team communication into one place, making it 
searchable and accessible anywhere. 

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
current version to the latest is supported. Always enure that 
you have a tested backup before proceeding with software updates.

See the Offical `Mattermost docs`_ for instructions on how to update.

Mattermost does not have a security only newsletter so we recommend that 
you subcribe to the `Mattermost Newsletter`_ to keep up to date.


Credentials *(passwords set at first boot)*
-------------------------------------------

-  Webmin, SSH: username **root**
-  PostgreSQL, Adminer: username **postgres**

	
.. _Mattermost: https://www.mattermost.org/
.. _TurnKey Core: https://www.turnkeylinux.org/core
.. _Adminer: http://adminer.org/
.. _Mattermost docs: http://docs.mattermost.com/administration/upgrade.html
.. _Mattermost Newsletter: http://mattermost.us11.list-manage.com/subscribe?u=6cdba22349ae374e188e7ab8e&id=2add1c8034

