#!/bin/sh

. /etc/ssvconfig/bin/ssvfunction
. /etc/ssvconfig/config/dyndns.cfg

PIDFILE=/var/run/inadyn.pid

configure()
{
	ssv_tmpl2file dyndns.cfg dyndns.conf /etc
}

start()
{
	if [ "$WUI_chk_service" = "on" ]; then
		ssv_logger 6 "starting"
		if inadyn --background --pid_file $PIDFILE --input_file /etc/dyndns.conf; then
			# Lets done first update
			test -n "$1" && sleep 1

			if [ ! -f $PIDFILE ]; then
				ssv_logger 3 "terminated shortly. Please check parameters!"
				exit 11
			fi
		else
			ssv_logger 3 "failed (error $?)"
			exit 10
		fi
	fi
}

stop()
{
	if [ -f $PIDFILE ]; then
		ssv_logger 6 "stopping"
		killall -SIGQUIT inadyn
		rm -f $PIDFILE
	fi
}

notify()
{
	if [ -f $PIDFILE ]; then
		ssv_logger 6 "notify"
		killall -HUP inadyn
	fi
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
	configure
	start delay
	;;
    configure)
	configure
	;;
    notify)
	notify
	;;
    *)
	echo "Usage: $0 {start|stop|restart|configure|notify}"
	exit 1
esac

exit 0
