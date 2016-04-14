WEBMIN_FW_TCP_INCOMING = 22 80 443 5432 12320 12321 12322

COMMON_OVERLAYS += adminer tkl-webcp lighttpd
COMMON_CONF += adminer-lighttpd adminer-pgsql tkl-webcp

include $(FAB_PATH)/common/mk/turnkey/pgsql.mk
include $(FAB_PATH)/common/mk/turnkey.mk
