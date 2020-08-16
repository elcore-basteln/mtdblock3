#!/bin/sh

start()
{
    /etc/ssvconfig/init.d/cron.sh start
    /etc/ssvconfig/init.d/network.sh start
    #/etc/ssvconfig/init.d/firewall.sh start
    /etc/ssvconfig/init.d/webconfig.sh start
    /etc/ssvconfig/init.d/openssh.sh start
    /etc/ssvconfig/init.d/lighttpd.sh start
    /etc/ssvconfig/init.d/openvpn start
    /etc/ssvconfig/init.d/fde_server.sh start
}

stop()
{
    /etc/ssvconfig/init.d/fde_server.sh stop
    #/etc/ssvconfig/init.d/webconfig.sh stop
    #/etc/ssvconfig/init.d/openvpn stop
    #/etc/ssvconfig/init.d/openssh.sh stop
    #/etc/ssvconfig/init.d/services.sh stop
    #/etc/ssvconfig/init.d/firewall stop
    #/etc/ssvconfig/init.d/time.sh stop
}

case "$1" in
    start|restart)
	start
	;;
    stop)
	stop
	;;
    *)
	echo "Usage: /etc/init.d/ssvstart.sh {start|stop}"
	exit 1
esac

exit 0
