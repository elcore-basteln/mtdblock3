#!/bin/sh

. /etc/ssvconfig/bin/ssvfunction
. /etc/ssvconfig/config/fde_mqtt.cfg
. /etc/ssvconfig/config/system.cfg

DAEMON=/usr/local/bin/fde_mqtt
DESC="FDE mqtt handler daemon"

test -f $DAEMON || exit 0

start()
{
    if [ "$WUI_chk_service" = "on" ]; then
    	echo "Starting $DESC"
	CLIENTID=`cat /sys/class/net/eth0/address | sed -e 's/://g'`
    	ARGS="-stcp://${WUI_serveraddr} -c$CLIENTID -p$WUI_serial -v$WUI_loglevel -r$WUI_resend"
        [ -n "$WUI_interval" ] && ARGS=$ARGS" -i $WUI_interval"
        $DAEMON $ARGS
    fi
}

stop()
{
	echo -n "Stopping $DESC"
	PID=`cat /var/run/fde/fde_mqtt.pid 2>/dev/null`
	kill $PID 2>/dev/null

	loop=0
	while [ $loop -lt 5 ]
	do
		if ! pidof fde_mqtt >/dev/null 2>&1
		then
			echo
			return
		fi
		loop=$(( $loop + 1 ))
		echo -n "."
		sleep 1
	done

	echo
	echo "Killing $DESC"
	kill -9 $PID
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
	start
	;;
    configure)
	;;
    *)
	echo "Usage: $0 {start|stop|restart|configure}"
	exit 1
	;;
esac

exit 0
