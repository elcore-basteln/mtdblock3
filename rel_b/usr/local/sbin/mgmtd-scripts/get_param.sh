#!/bin/sh

. /etc/ssvconfig/config/system.cfg
logger -t mgmt get_param
echo -n "Build $WUI_swbuild - "$(uname -a)

