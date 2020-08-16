#! /bin/sh
#
#set -x

[ -f /tmp/watchdog.disable ] && exit 0
#run intervall is 5 sec
UPTIME=$(cat /proc/uptime | cut -d'.' -f1)
WD_ERR=0
WD_COUNT=0
WD_REPAIR=0
WD_TESTCOUNT=3		#test on > x runs
WD_RUNTESTS="test_fde test_vpn test_http test_webconf"
WD_RUNREPAIR=""

problem(){
    logger "$1 problem"
#    echo "$1 problem"
    WD_ERR=1
    WD_RUNREPAIR=$WD_RUNREPAIR"$1 "
}

test_fde(){
    case "$1" in
    test)
	. /etc/ssvconfig/config/fde_server.cfg
	if [ "$WUI_chk_service" = "on" ]; then
	    pidof fde_server 1>/dev/null || problem "test_fde"
	    . /etc/ssvconfig/config/fde_mqtt.cfg
	    if [ "$WUI_chk_service" = "on" ]; then
	        pidof fde_mqtt 1>/dev/null || problem "test_fde"
	    fi
	fi
	;;
    repair)
	/etc/ssvconfig/init.d/fde_server.sh restart
	;;
    esac
}
test_vpn(){
    case "$1" in
    test)
	. /etc/ssvconfig/config/openvpn
	[ "$SSV_OPENVPN_ON" = "on" -a "x$(pidof openvpn)" = "x" ] && problem "test_vpn"
	;;
    repair)
	/etc/ssvconfig/init.d/openvpn restart
	;;
    esac
}
test_http(){
    case "$1" in
    test)	
	. /etc/ssvconfig/config/services.cfg
	if [ "$WUI_chk_http" = "on" ]; then
	    [ ! -f /var/run/lighttpd.pid ] && problem "test_http"
	fi
	;;
    repair)
        /etc/ssvconfig/init.d/lighttpd.sh restart
        ;;
    esac
}
test_webconf(){
    case "$1" in
    test)
	. /etc/ssvconfig/config/webconfig.cfg
	if [ "$WUI_chk_service" = "on" ]; then
	    [ ! -f /var/run/webconfig.pid ] && problem "test_webconf"
	fi
	;;
    repair)
        /etc/ssvconfig/init.d/webconfig.sh restart
        ;;
    esac
}

if [ $UPTIME -lt 120 ]; then
    [ -f /tmp/watchdog.startup ] || touch /tmp/watchdog.startup
    exit 0
else
    rm -f /tmp/watchdog.startup
fi

[ -f /tmp/watchdog.counter ] && WD_COUNT=$(cat /tmp/watchdog.counter)
WD_COUNT=$(($WD_COUNT + 1))

if [ $WD_COUNT -gt $WD_TESTCOUNT ]; then
    for i in ${WD_RUNTESTS}; do
        $i test
    done
    [ $WD_ERR -eq 0 ] && WD_COUNT=0
fi

if [ $WD_ERR -ne 0 ]; then
    [ -f /tmp/watchdog.repair ] && WD_REPAIR=$(cat /tmp/watchdog.repair)
    WD_REPAIR=$(($WD_REPAIR + 1))
    if [ $WD_REPAIR -gt 1 ]; then
	for i in ${WD_RUNREPAIR}; do
    	    $i repair
	done
	WD_COUNT=0
    fi
fi

if [ $WD_REPAIR -gt 3 ]; then
    exit -1
fi

echo $WD_REPAIR >/tmp/watchdog.repair
echo $WD_COUNT >/tmp/watchdog.counter

exit 0
