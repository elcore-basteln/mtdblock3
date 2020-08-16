#! /bin/sh
#
# Description:     Set the Hostname of System
# Version:      3.00  01.09.2009  ene@SSV
#

. /etc/ssvconfig/config/system.cfg

start(){
    if [ "x$WUI_hostname" != "x" ]; then
        echo "$WUI_hostname" > /etc/hostname
        hostname $WUI_hostname
    fi
}

case "$1" in
    stop)
	;;
    start|restart)
	start
	;;
    configure)
	;;
    *)
    echo "Usage: {start|stop|restart|configure}"
esac

exit 0
