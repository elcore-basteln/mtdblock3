#!/bin/sh

. /etc/ssvconfig/bin/ssvfunction
. /etc/ssvconfig/config/time.cfg

DAEMON=/sbin/ntpclient
[ -n "$WUI_ntp" -a "$WUI_sel_ntp" == "user" ] && SERVER=$WUI_ntp || SERVER=$WUI_sel_ntp
TIMEOUT=3

settime()
{
    if [ "x$WUI_chk_setup" = "xntp" ]; then
	OLD=`date +%Y`
	if ! $DAEMON -h $SERVER -s -i $TIMEOUT >/dev/null 2>/dev/null; then
	    ssv_logger 3 "Time synchronization failed"
	    exit 10
	fi
	if [ `date +%Y` -lt 2012 ]; then
	    ssv_logger 3 "Date is wrong"
	    exit 10
	fi
	if [ -f /var/run/cron.pid -a $OLD -lt 2012 ]; then
	    ssv_logger 3 "Big time jump, restarting cron"
	    ( 	sleep 3; \
		/etc/ssvconfig/init.d/cron.sh restart; \
		/etc/ssvconfig/init.d/webconfig.sh restart; \
		/etc/ssvconfig/init.d/lighttpd.sh restart; \
	    ) >/dev/null 2>&1 </dev/null &
	fi
    elif [ "x$WUI_chk_setup" = "xman" -a "x$1" != "x" ]; then
        ssv_logger 6 "Set date to '$1'"
        /bin/date $1
        if [ $? -ne 0 ]; then
	    ssv_logger 3 "Date is wrong"
	    exit 10
	fi
    else
	ssv_logger 3 "NTP service not configured"
	exit 11
    fi
    hwclock -w
}

configure()
{
    if ! test /usr/share/zoneinfo/$WUI_sel_tz -ef /etc/localtime; then
	ssv_logger 6 "Set timezone to $WUI_sel_tz"
	ln -sf /usr/share/zoneinfo/$WUI_sel_tz /etc/localtime
    fi

    SSV_TIME_SYNC_M="1"
    SSV_TIME_SYNC_H="*/$WUI_sel_sync"
    export SSV_TIME_SYNC_M SSV_TIME_SYNC_H
    ssv_tmpl2file time.cfg crontab /etc
}

case "$1" in
    start)
        settime
	;;
    stop)
	;;
    restart)
        configure
        settime $2
	;;
    configure)
        configure
	;;
    settime)
        settime $2
	;;
    *)
	echo "Usage: {start|stop|restart|configure|settime [DATE]}"
	exit 1
esac

exit 0
