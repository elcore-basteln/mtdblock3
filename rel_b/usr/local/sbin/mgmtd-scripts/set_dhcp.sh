#!/bin/sh

logger -t mgmt "set_dhcp $1"
grep -v 'SSV_ETH0_MODUS' </etc/ssvconfig/config/network >/tmp/mgmt.tmp
echo "SSV_ETH0_MODUS=\"$1\"" >>/tmp/mgmt.tmp
mv /tmp/mgmt.tmp /etc/ssvconfig/config/network
