#!/bin/sh

. /etc/mgmtd.conf
logger -t mgmt get_ip
ifconfig $NETDEV | sed -ne 's/^.*inet addr:\([0-9\.]*\).*$/\1/p'
