#!/bin/sh
# hwclock.sh 	Set system clock to hardware clock
#
# Version:      1.00  01.03.2009  ene@SSV
#

. /etc/profile
. /etc/init.d/functions

HWCLOCK=/usr/local/bin/clock-sbc9263a

[ ! -x ${HWCLOCK} ] && { date -s "070900002009" > /dev/null ; exit 0 ; }

case "$1" in
    start)
        g_echo -n "Setting the System Clock from RTC.........................."
	SYSTEMDATEMIN="20081010"
	${HWCLOCK} -s
	SYSTEMDATE=`date "+%Y%m%d"`
	NEEDUPDATE=`expr \( $SYSTEMDATEMIN \> $SYSTEMDATE \)`
	if [ $NEEDUPDATE -eq 1 ]; then
	    date -s "101000002008"
	fi
	g_echo "done"
        ;;
    stop)
        ;;
    *)
        echo "Usage: hwclock.sh {start|stop}"
        exit 1
        ;;
esac

exit 0
