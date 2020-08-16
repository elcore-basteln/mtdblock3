#!/bin/sh
#
# lighttpd      Start and stop the web server for wegconfig
#
# Version:      2.00  16.10.2012  ene@SSV
#

. /etc/ssvconfig/bin/ssvfunction
. /etc/ssvconfig/config/webconfig.cfg

PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin
DAEMON=/usr/sbin/lighttpd
PIDFILE=/var/run/webconfig.pid
ARGS="-f /etc/lighttpd/webconfig.conf"
mkdir -p /tmp/webgui/upload
mkdir -p /tmp/webgui/download

case "$1" in
    start)
        echo -n "Starting WebConfig Server.................................."
        [ $WUI_chk_service != 'on' ] && echo "disabled" && exit 0
        start-stop-daemon -S -b -q -p $PIDFILE -x $DAEMON -- ${ARGS}
        [ $? -eq 0 ] && echo "done" || echo "faild"
	;;
    stop)
        echo -n "Stopping WebConfig Server.................................."
        start-stop-daemon -K -s SIGINT -q -p $PIDFILE -x $DAEMON
        echo "done"
	;;
    restart)
        start-stop-daemon -K -s SIGINT -q -p $PIDFILE -x $DAEMON
        sleep 1
        start-stop-daemon -S -b -q -p $PIDFILE -x $DAEMON -- ${ARGS}
	;;
    configure)
	;;
    *)
	echo "Usage: $0 {start|stop|restart|configure}" >&2
	exit 1
	;;
esac

exit 0
