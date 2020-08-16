#!/bin/sh

. /etc/ssvconfig/bin/ssvfunction
. /etc/ssvconfig/config/services.cfg

DAEMON=/usr/local/sbin/upnphd
IFACE=$2

[ "x$IFACE" = "x" ] && IFACE=eth0
IP=`ifconfig $IFACE | sed -ne 's/^.*inet addr:\([0-9\.]*\).*$/\1/p' 2>/dev/null`
PIDFILE=/var/run/upnphd-$IFACE.pid

test -f $DAEMON || exit 0
set -e

start()
{
	echo -n "Starting UPnP Service......................................"
	[ "$WUI_chk_upnp" != "on" ] && echo "disabled" && exit 0
	$DAEMON -p $PIDFILE -i $IP -n "$IFACE" >/dev/null 2>/dev/null
	[ $? -eq 0 ] && echo -n "done" || echo -n "faild"
	echo " [$IFACE]" 
}

stop()
{
	echo -n "Stopping UPnP Service......................................"
	kill `cat $PIDFILE 2>/dev/null`
	[ $? -eq 0 ] && echo "done" || echo "faild"
}

case "$1" in
    start)
        start
	;;
    stop)
        stop
	;;
    restart)
        if [ -f $PIDFILE ]; then
            stop
            sleep 1
        fi
        start
	;;
    configure)
        ;;
    *)
	echo "Usage: $0 {start|stop|restart|configure [IFACE]}" >&2
	exit 1
	;;
esac

exit 0
