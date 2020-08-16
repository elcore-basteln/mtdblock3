#!/bin/sh

. /etc/ssvconfig/bin/ssvfunction

case "$1" in
    start)
        /etc/init.d/cron start
	;;
    stop)
        /etc/init.d/cron stop
	;;
    restart)
        /etc/init.d/cron stop
	sleep 1
	/etc/init.d/cron start
	;;
    configure)
	;;
    *)
	echo "Usage: {start|stop|restart|configure}"
	exit 1
esac

exit 0
