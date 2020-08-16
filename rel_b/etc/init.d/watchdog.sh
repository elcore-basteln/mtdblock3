#! /bin/sh
#
# watchdog      Start and stop the watchdog daemon
#
# Version:      1.00  01.03.2009  ene@SSV
#

test -c /dev/watchdog || exit 0

case "$1" in
    start)
	killall wd_keepalive
	watchdog -c /etc/watchdog_sys.conf
	;;
    stop)
	killall wd_keepalive
	killall watchdog
	;;
    *)
	echo "Usage: $0 {start|stop}" >&2
	exit 1
	;;
esac

exit 0
