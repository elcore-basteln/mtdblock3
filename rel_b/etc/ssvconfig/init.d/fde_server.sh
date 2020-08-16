#!/bin/sh

. /etc/ssvconfig/bin/ssvfunction
. /etc/ssvconfig/config/fde_server.cfg

DAEMON=/usr/local/bin/fde_server
DESC="FDE device server"
CLIENTS="fde_mqtt"

test -f $DAEMON || exit 0

clients()
{
	for i in ${CLIENTS}; do
		if [ -x /etc/ssvconfig/init.d/${i}.sh ]; then
			/etc/ssvconfig/init.d/${i}.sh ${1}
		fi
	done
}

start()
{
	if [ "$WUI_chk_service" = "on" ]; then
		echo "Starting $DESC"
		ssvconfig set comport.cfg WUI_sel_com2_app none
		/etc/ssvconfig/init.d/comport.sh restart
		sleep 1
		$DAEMON -v$WUI_loglevel -c $WUI_cfg_file
		clients start
	fi
}

stop()
{
    	echo -n "Stopping $DESC"
	clients stop
	PID=`cat /var/run/fde/fde_server.pid 2>/dev/null`
	kill $PID 2>/dev/null

	loop=0
	while [ $loop -lt 5 ]; do
		if ! pidof fde_server >/dev/null 2>&1; then
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
	sleep 1
	start
	;;
    configure)
	;;
    scan)
	test -z "$2" && exit 1
	stop
	sleep 1
	$DAEMON -v6 $2
	;;
    dump)
	fde_dump
	;;
    *)
	echo "Usage: $0 {start|stop|restart|configure|scan|dump}"
	exit 1
	;;
esac

exit 0
