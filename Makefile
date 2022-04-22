WEBMIN_FW_TCP_INCOMING = 22 80 443 12320 12321 12322

COMMON_OVERLAYS += adminer
COMMON_CONF += adminer-pgsql adminer-nginx

include $(FAB_PATH)/common/mk/turnkey/nginx.mk
include $(FAB_PATH)/common/mk/turnkey/php-fpm.mk
include $(FAB_PATH)/common/mk/turnkey/pgsql.mk
include $(FAB_PATH)/common/mk/turnkey.mk
