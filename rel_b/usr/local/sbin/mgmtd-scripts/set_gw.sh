#!/bin/sh

. /etc/mgmtd.conf
logger -t mgmt "set_gw $1"

grep -v 'SSV_DGW' </etc/ssvconfig/config/network >/tmp/mgmt.tmp
if [ -n "$1" -a "$1" != "0.0.0.0" ]
then
	. /etc/ssvconfig/config/network
	if [ "$SSV_ETH0_MODUS" = "static" ]
	then
		echo "SSV_DGW_ON=\"yes\"" >>/tmp/mgmt.tmp
		echo "SSV_DGW=\"$1\"" >>/tmp/mgmt.tmp
	else
		logger -t mgmt "Skip GW while DHCP"
		echo "SSV_DGW_ON=\"no\"" >>/tmp/mgmt.tmp
	fi
else
	echo "SSV_DGW_ON=\"no\"" >>/tmp/mgmt.tmp
fi
mv /tmp/mgmt.tmp /etc/ssvconfig/config/network
