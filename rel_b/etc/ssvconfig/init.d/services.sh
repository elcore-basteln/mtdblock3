#!/bin/sh

. /etc/ssvconfig/bin/ssvfunction
. /etc/ssvconfig/config/services.cfg

configure()
{
    ssv_tmpl2file services.cfg inetd.conf /etc
}

check_proc(){
    grep -q $1 /proc/$(cat $2 2>/dev/null)/cmdline && echo "on" || echo "off"
}
check_pidof(){
    pidof $1 >/dev/null && echo "on" || echo "off"
}
check_inetd(){
    grep -q "^$1" /etc/inetd.conf && echo "on" || echo "off" 
}
restart()
{
    if [ "$(check_proc upnphd /var/run/upnphd-eth0.pid)" != "$WUI_chk_upnp" ]; then 
	/etc/ssvconfig/init.d/upnp.sh restart
    fi
    if [ "$(check_pidof /usr/local/sbin/avahi-autoipd)" != "$WUI_chk_autoip" ]; then 
	/etc/ssvconfig/init.d/avahi-autoipd stop
	/etc/ssvconfig/init.d/avahi-autoipd start
    fi
    if [ "$(check_proc lighttpd /var/run/lighttpd.pid)" != "$WUI_chk_http" ]; then
	/etc/ssvconfig/init.d/lighttpd.sh restart
    fi
    if [ "$(check_pidof mgmtd)" != "$WUI_chk_mgmtd" ]; then
	/etc/ssvconfig/init.d/mgmtd stop
	/etc/ssvconfig/init.d/tmdns restart
	/etc/ssvconfig/init.d/mgmtd start
    fi
    RESTARTINIT=0
    if [ "$(check_inetd telnet)" != "$WUI_chk_telnet" ]; then
        killall in.telnetd 2>/dev/null
        RESTARTINIT=1
    fi
    if [ "$(check_inetd ftp)" != "$WUI_chk_ftp" ]; then
        killall in.ftpd 2>/dev/null
        RESTARTINIT=1
    fi
    if [ "$(check_inetd tftp)" != "$WUI_chk_tftp" ]; then
        killall in.tftpd 2>/dev/null
        RESTARTINIT=1
    fi
    if [ "$RESTARTINIT" = "1" -o "$(check_inetd time)" != "$WUI_chk_time" ]; then
        configure
        /etc/init.d/inetd restart
    fi
}

case "$1" in
    start)
	restart
	;;
    stop)
	;;
    restart)
	restart
	;;
    configure)
	configure
	;;
    *)
	echo "Usage: $0 {start|stop|restart|configure}"
	exit 1
esac

exit 0
