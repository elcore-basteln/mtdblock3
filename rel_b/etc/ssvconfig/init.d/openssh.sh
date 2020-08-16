#!/bin/sh

. /etc/ssvconfig/bin/ssvfunction
. /etc/ssvconfig/config/openssh.cfg

configure()
{
	ssv_tmpl2file openssh.cfg sshd_config /etc/ssh
}

start()
{
	echo -n "Starting SSH Server........................................"
	mkdir -p /var/run/sshd
	if [ "$WUI_chk_service" = "on" ]; then
		/usr/sbin/sshd -f /etc/ssh/sshd_config 2>/dev/null >/dev/null
		if [ $? -eq 0 ]; then
			echo "done" 
			ssv_logger 7 "SSH Server started"
		else
			echo "faild"
			ssv_logger 7 "Failed to start SSH Server"
		fi
	else
		echo "disabled"
	fi
}

stop()
{	
	echo -n "Stopping SSH Server........................................"
	killall sshd 2>/dev/null
	if [ $? -eq 0 ]; then
		echo "done" 
		ssv_logger 7 "SSH Server stopped"
	else
		echo "faild"
		ssv_logger 7 "Can't stop SSH Server"
	fi
}

makekey()
{
	pidof ssh-keygen >/dev/null 2>/dev/null && exit 0

	ssv_logger 7 "Generate ssh keys"
	rm -f /tmp/ssvconfig/ssh_host_*
	ssh-keygen -v -f /tmp/ssvconfig/ssh_host_key -N '' -t rsa1
	ssh-keygen -v -f /tmp/ssvconfig/ssh_host_rsa_key -N '' -t rsa
	ssh-keygen -v -f /tmp/ssvconfig/ssh_host_dsa_key -N '' -t dsa
	mv /tmp/ssvconfig/ssh_host_* /etc/ssh/
	ssv_logger 7 "New ssh keys created"
}

fingerprint()
{
    echo "WUI_rsa_key='"`ssh-keygen -lf /etc/ssh/ssh_host_rsa_key.pub | cut -d' ' -f2`"'"
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
	start
	;;
    configure)
	configure
	;;
    makekey)
	makekey
	;;
    fingerprint)
	fingerprint
	;;
    *)
	echo "Usage: $0 {start|stop|restart|configure|makekey|fingerprint}"
	exit 1
esac

exit 0
