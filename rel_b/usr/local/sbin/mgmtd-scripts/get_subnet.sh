#!/bin/sh

. /etc/mgmtd.conf
logger -t mgmt get_subnet
ifconfig $NETDEV | sed -ne 's/^.*Mask:\([0-9\.]*\).*$/\1/p'
