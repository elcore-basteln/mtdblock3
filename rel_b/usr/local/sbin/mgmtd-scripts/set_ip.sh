#!/bin/sh

logger -t mgmt "set_ip $1"
grep -v 'SSV_ETH0_IP' </etc/ssvconfig/config/network >/tmp/mgmt.tmp
echo "SSV_ETH0_IP=\"$1\"" >>/tmp/mgmt.tmp
mv /tmp/mgmt.tmp /etc/ssvconfig/config/network
