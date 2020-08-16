#!/bin/sh

. /etc/mgmtd.conf
logger -t mgmt get_gw
route -n | sed -ne "s/^0\.0\.0\.0[^0-9\.]*\([0-9\.]*\).*$NETDEV\$/\1/p"
