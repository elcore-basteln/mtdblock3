#!/bin/sh
#
# lighttpd      Start and stop the web server daemon
#
# Version:      2.00  16.10.2012  ene@SSV
#

. /etc/ssvconfig/bin/ssvfunction
. /etc/ssvconfig/config/services.cfg

PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin
DAEMON=/usr/sbin/lighttpd
PIDFILE=/var/run/lighttpd.pid
ARGS="-f /etc/lighttpd/lighttpd.conf"

start() {
	echo -n "Starting Lighttpd Web Server..............................."
	[ "$WUI_chk_http" != "on" ] && echo "disabled" && exit 0
	start-stop-daemon -S -b -q -p $PIDFILE -x $DAEMON -- ${ARGS}	
	[ $? -eq 0 ] && echo "done" || echo "faild"
}

stop() {
	echo -n "Stopping Lighttpd Web Server..............................."
	start-stop-daemon -K -q -p $PIDFILE -x $DAEMON
	echo "done"
}

case "$1" in
    start)
	start
	;;
    stop)
	stop
	;;
    restart)
	stop
	sleep 1
	start
	;;
    configure)
        ;;
    *)
	echo "Usage: $0 {start|stop|restart|configure}" >&2
	exit 1
	;;
esac

exit 0
