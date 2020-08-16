#!/bin/sh

. /etc/ssvconfig/config/network
logger -t mgmt get_dhcp
echo "$SSV_ETH0_MODUS"
