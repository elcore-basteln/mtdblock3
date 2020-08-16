#! /bin/sh
#
# Description:    get information/status of the system
# Output Format is WUI_name='value'\n
# Version:      3.00  01.09.2009  ene@SSV
#

SYS_CFG=/etc/ssvconfig/config/system.cfg

2>/dev/null

status()
{
#########################################################################
# hostname lokation und kontakt informationen
echo "WUI_hostname='$(hostname)'"
if [ -f $SYS_CFG ]; then
    . $SYS_CFG
    echo "WUI_location='$WUI_location'"
    echo "WUI_contact='$WUI_contact'"
else
    echo "WUI_location='not set'"
    echo "WUI_contact='not set'"
fi
#########################################################################
# lan interface eth0 informationen
set -- `/sbin/ifconfig eth0|sed -n 's/\(.* HWaddr \([0-9A-F:]*\).*\)\|\( *inet addr:\([0-9.]*\).*Mask:\([0-9.]*\)\)$/\2 \4 \5/p'`
echo "WUI_eth0_mac='$1'"
if [ -n "$2" -a -n "$3" ]; then
	echo "WUI_eth0_ip='$2'"
	echo "WUI_eth0_netmask='$3'"
else
	set -- `/sbin/ifconfig br0 2>/dev/null|sed -n 's/ *inet addr:\([0-9.]*\).*Mask:\([0-9.]*\)$/\1 \2/p'`
	if [ -n "$1" -a -n "$2" ]; then
		echo "WUI_eth0_ip='$1 (bridged)'"
		echo "WUI_eth0_netmask='$2'"
	else
		set -- `/sbin/ifconfig eth0:auto 2>/dev/null|sed -n 's/ *inet addr:\([0-9.]*\).*Mask:\([0-9.]*\)$/\1 \2/p'`
		if [ -n "$1" -a -n "$2" ]; then
			echo "WUI_eth0_ip='$1 (AutoIP)'"
			echo "WUI_eth0_netmask='$2'"
		else
			echo "WUI_eth0_ip='disabled'"
			echo "WUI_eth0_netmask='disabled'"
		fi
	fi
fi
#########################################################################
# lan interface eth1 informationen
if [ -d /sys/class/net/eth1 ]; then
	set -- `/sbin/ifconfig eth1|sed -n 's/\(.* HWaddr \([0-9A-F:]*\).*\)\|\( *inet addr:\([0-9.]*\).*Mask:\([0-9.]*\)\)$/\2 \4 \5/p'`
	echo "WUI_eth1_mac='$1'"
	if [ -n "$2" -a -n "$3" ]; then
		echo "WUI_eth1_ip='$2'"
		echo "WUI_eth1_netmask='$3'"
	else
		echo "WUI_eth1_ip='disabled'"
		echo "WUI_eth1_netmask='disabled'"
	fi
fi
#########################################################################
# lan interface eth0 informationen
if [ -d /sys/class/net/ppp0 ]; then
    set -- `/sbin/ifconfig ppp0|sed -n 's/ *inet addr:\([0-9.]*\).*Mask:\([0-9.]*\)$/\1 \2/p'`
    if [ -n "$1" -a -n "$2" ]; then
        echo "WUI_ppp0_ip='$1'"
        echo "WUI_ppp0_netmask='$2'"
    else
        echo "WUI_ppp0_ip='offline'"
        echo "WUI_ppp0_netmask='offline'"
    fi
else
    echo "WUI_ppp0_ip='offline'"
    echo "WUI_ppp0_netmask='offline'"		
fi
#########################################################################
# lan interface eth0:0 informationen (alias)
set -- `/sbin/ifconfig eth0:0|sed -n 's/ *inet addr:\([0-9.]*\).*Mask:\([0-9.]*\)$/\1 \2/p'`
if [ -n "$1" -a -n "$2" ]; then
	echo "WUI_eth00_ip='$1'"
	echo "WUI_eth00_netmask='$2'"
else
	echo "WUI_eth00_ip='disabled'"
	echo "WUI_eth00_netmask='disabled'"
fi
#########################################################################
# VPN interface tun0/tap0 informationen
vpnsta()
{
	DEV=$1
	set -- `/sbin/ifconfig $DEV|sed -ne 's/ *inet addr:\([0-9.]*\).*Mask:\([0-9.]*\)$/\1 \2/p' -e 's/^.*RUNNING.*$/RUN/p'`
	if [ -n "$1" -a -n "$2" ]; then
		echo "WUI_vpn_ip='$1'"
		echo "WUI_vpn_netmask='$2'"
	else
		if [ "x$1" = "xRUN" ]
		then
			echo "WUI_vpn_ip='not set (bridged)'"
			echo "WUI_vpn_netmask='not set'"
		else
			echo "WUI_vpn_ip='offline'"
			echo "WUI_vpn_netmask='offline'"
		fi
	fi
}

if [ -d /sys/class/net/tap0 ]
then
	vpnsta tap0
elif [ -d /sys/class/net/tun0 ]
then
	vpnsta tun0
else
	if /sbin/pidof openvpn >/dev/null; then
		echo "WUI_vpn_ip='offline'"
		echo "WUI_vpn_netmask='offline'"
	else
		echo "WUI_vpn_ip='disabled'"
		echo "WUI_vpn_netmask='disabled'"
	fi
fi
#########################################################################
# default gateway informationen
RT=`/sbin/route -n | sed -ne 's/^0\.0\.0\.0[^0-9\.]*\([0-9\.]*\).*\$/\1/p'`
echo "WUI_gateway='$([ -n "$RT" ] && echo $RT || echo "disabled")'"

#########################################################################
# nameserver informationen
set -- `grep "nameserver " /etc/resolv.conf | cut -f2 -d' '`
echo "WUI_dns1='$([ -n "$1" ] && echo $1 || echo "not set")'"
echo "WUI_dns2='$([ -n "$2" ] && echo $2 || echo "not set")'"
echo "WUI_dns3='$([ -n "$3" ] && echo $3 || echo "not set")'"
}

case "$1" in
    getstatus)
	status 
	;;
    *)
	echo "Usage: $0 {getstatus}"
	exit 1
esac

exit 0
