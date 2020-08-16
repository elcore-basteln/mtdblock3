#!/bin/sh

logger -t mgmt "set_subnet $1"
grep -v 'SSV_ETH0_NM' </etc/ssvconfig/config/network >/tmp/mgmt.tmp
echo "SSV_ETH0_NM=\"$1\"" >>/tmp/mgmt.tmp
mv /tmp/mgmt.tmp /etc/ssvconfig/config/network
