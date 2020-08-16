#! /bin/sh
#
# keepalive     This script handle the watchdog untill system starting
#
# Version:      1.00  01.03.2009  ene@SSV
#

test -c /dev/watchdog || exit 0

case "$1" in
    start)
	wd_keepalive
	;;
    stop)
	killall wd_keepalive
	;;
    *)
	echo "Usage: $0 {start|stop}" >&2
	exit 1
	;;
esac

exit 0
