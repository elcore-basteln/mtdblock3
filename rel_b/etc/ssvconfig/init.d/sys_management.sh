#! /bin/sh
#
# Description:     system management to hald and reboot the system
# Version:      3.00  01.09.2009  ene@SSV
#

. /etc/ssvconfig/bin/ssvfunction
. /etc/ssvconfig/config/system.cfg

reboot(){
    exec /sbin/reboot
}
halt(){
    killall -9 shutdown
    exec /sbin/halt
}
stop(){
    killall -9 shutdown
}
start(){
    [ $WUI_auto_halt_time -eq 0 ] && return
    SHUTDOWN_TIME=`expr $WUI_auto_halt_time \* 60`
    /sbin/shutdown -h +$SHUTDOWN_TIME &
}

changepw()
{
	if echo "$1:$2" | chpasswd -m; then
		ssv_logger 7 "password for $1 changed"
		exit 0
	else
		ssv_logger 7 "chpasswd failed"
		exit 1
	fi
}

case "$1" in
    reboot)
	reboot
	;;
    halt)
	halt
	;;
    stop)
	stop
	;;
    start)
	start
	;;
    restart)
	stop
	start
	;;
    configure)
	;;
    changepw)
	changepw $2 $3
	;;
    *)
	echo "Usage: $0 {start|restart|configure|reboot|halt|changepw USER PASS}"
	exit 1
esac

exit 0
