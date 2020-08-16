#!/bin/sh

[ "x$FW_ACT_REL" = "x" ] && exit 0

start()
{
	#todo get active release
	mount | grep -q '/dev/mtdblock3 on /usr/local type jffs2 (rw)'
	if [ $? -ne 0 ]; then
		echo -n "Mounting /flash/$FW_ACT_REL/usr/local............................"
		mount -n --bind /flash/$FW_ACT_REL/usr/local /usr/local && echo "done" || echo "failed"
	fi
	mount | grep -q '/dev/mtdblock3 on /etc type jffs2 (rw)'
	if [ $? -ne 0 ]; then
		echo -n "Mounting /flash/$FW_ACT_REL/etc.................................."
		mount -n --bind /flash/$FW_ACT_REL/etc /etc && echo "done" || echo "failed"
	fi
	
	# Hardware
	insmod /lib/modules/ssvpio.ko
	pidof ledstatd >/dev/null || ledstatd C4 2>/dev/null >/dev/null &
	mkdir -p /tmp/ssvconfig
	mkdir -p /var/volatile/state
	mkdir -p /var/volatile/lib
	mkdir -p /var/volatile/empty
	
	if [ ! -f /etc/init.d/ssv-ssvstart.sh ]; then
		ln -sf /etc/ssvconfig/init.d/ssvstart.sh /etc/init.d/ssv-ssvstart.sh
		update-rc.d -f ssv-ssvstart.sh start 99 5 . stop 70 0 6 1 .
	fi
	ledstat 1 2
	#kill -1 1
}

case "$1" in
	start)
	start
	;;
	stop)
	;;
	configure)
	;;
	*)
	echo "Usage: /etc/init.d/ssvinit.sh {start|stop|configure}"
	exit 1
esac

exit 0
