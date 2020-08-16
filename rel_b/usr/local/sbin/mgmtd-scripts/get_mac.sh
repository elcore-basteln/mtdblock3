#!/bin/sh

. /etc/mgmtd.conf
logger -t mgmt get_mac
ifconfig $NETDEV | sed -ne 's/^.*HWaddr \([0-9A-F:]*\).*$/\1/p'

