#!/bin/sh

. /etc/ssvconfig/bin/ssvfunction
. /etc/ssvconfig/config/network.cfg

NETWORK_STARTED="/var/cache/network-started"
# state udhcpc: /etc/udhcpc.d/50default
S_DECONFIG="/var/cache/network-dhcp-deconfig"
S_BOUND="/var/cache/network-dhcp-bound"
S_LEASEFAIL="/var/cache/network-dhcp-leasefail"

config_dns()
{
	if [ -n "$1" -a "x$1" != "x..." ]; then
		echo "nameserver $1" >>/etc/resolv.conf
	fi
}

createdns()
{
	if [ "x$WUI_chk_dns" = "xon" ]; then
		echo "#ssvconfig: resolv.conf" >/etc/resolv.conf
		config_dns $WUI_dns1_ip
		config_dns $WUI_dns2_ip
		config_dns $WUI_dns3_ip
	fi
}

configure()
{
    ssv_tmpl2file network.cfg interfaces.eth0 /etc/network
    cat /etc/network/interfaces.* >/etc/network/interfaces
    createdns
    sync
}

spoofprotect () {
    # This is the best method: turn on Source Address Verification and get
    # spoof protection on all current and future interfaces.
    echo -n "Setting up IP spoofing protection.........................."
    if [ -e /proc/sys/net/ipv4/conf/all/rp_filter ]; then
        for f in /proc/sys/net/ipv4/conf/*; do
            [ -e $f/rp_filter ] && echo 1 > $f/rp_filter
        done
        echo "done"
    else
        echo "failed"
    fi
}

start()
{
    spoofprotect
    [ -f /etc/hostname ] && hostname -F /etc/hostname
    echo -n "Configuring network interfaces............................."
    if sed -n 's/^[^ ]* \([^ ]*\) \([^ ]*\) .*$/\1 \2/p' /proc/mounts | grep -q "^/ nfs$"; then
	echo "[skip]"
    else
	ssv_logger 7 "Starting Network lo"
	ifup lo >/dev/null 2>/dev/null
	if [ ! -f ${NETWORK_STARTED} ]; then
    	    ssv_logger 7 "Starting Network eth0"
	    : > ${NETWORK_STARTED}
	    rm -f ${S_DECONFIG} ${S_BOUND} ${S_LEASEFAIL}
	    ifup eth0 >/dev/null 2>/dev/null &
	fi
	echo "done"
    fi
}

stop()
{
    echo -n "Stop network interfaces...................................."
    if sed -n 's/^[^ ]* \([^ ]*\) \([^ ]*\) .*$/\1 \2/p' /proc/mounts | grep -q "^/ nfs$"; then
        echo "[skip]"
    else
	ssv_logger 7 "Stopping Network lo"
        ifdown lo
	ssv_logger 7 "Stopping Network eth0"
	if [ -f ${NETWORK_STARTED} ]; then
	    #stop ALL udhcpc.helper
	    kill $(cat /var/run/udhcpc.helper.pid.* 2>/dev/null) 2>/dev/null
	    rm -f ${NETWORK_STARTED}
	    sleep 1
	    ifdown eth0
	    usleep 250000
	    rm -f ${S_DECONFIG} ${S_BOUND} ${S_LEASEFAIL}
	fi
	echo "done"
    fi
}

case "$1" in
    final)
        test -s /etc/resolv.conf || createdns
	;;
    start)
        start
	;;
    stop)
        stop
	;;
    restart)
        stop
        configure
        start
	;;
    configure)
        configure
	;;
    probe)
        FILE=/tmp/probe$$.tmp
        if ping -c 1 "www.ssv-embedded.de" >/dev/null 2>$FILE; then
            ssv_logger 7 "Internet ok"
            ret=0
        else
            logger -t network.ping <$FILE
            if grep -q "Host name lookup failure" $FILE; then
                ret=2
            elif grep -q "Network is unreachable" $FILE; then
                ret=3
            elif grep -q "Unknown host" $FILE; then
                ret=4
            else
                ret=9
            fi
        fi
        rm $FILE
        exit $ret
	;;
    *)
	echo "Usage: $0 {start|stop|restart|configure|final}"
	exit 1
esac

exit 0
