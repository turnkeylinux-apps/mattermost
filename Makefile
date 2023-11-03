WEBMIN_FW_TCP_INCOMING = 22 80 443 8443 12321 12322
WEBMIN_FW_UDP_INCOMING = 8443

COMMON_OVERLAYS += adminer
COMMON_CONF += adminer-pgsql adminer-nginx

include $(FAB_PATH)/common/mk/turnkey/nginx.mk
include $(FAB_PATH)/common/mk/turnkey/php-fpm.mk
include $(FAB_PATH)/common/mk/turnkey/pgsql.mk
include $(FAB_PATH)/common/mk/turnkey.mk
