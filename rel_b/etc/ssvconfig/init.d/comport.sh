#!/bin/sh

. /etc/ssvconfig/bin/ssvfunction
. /etc/ssvconfig/default/global
. /etc/ssvconfig/config/comport.cfg


if [ "x$WUI_sel_com1_app" = "xsocat" ]; then
	[ "x$WUI_sel_com1_stop" = "x1" ] && STOPBITS="cstopb=0" || STOPBITS="cstopb=1"
	case "$WUI_sel_com1_parity" in
		n) PARITY="parenb=0" ;;
		o) PARITY="parenb=1,parodd=1" ;;
		e) PARITY="parenb=1,parodd=0" ;;
		m) PARITY="parenb=1,parmrk=1" ;;
		s) PARITY="parenb=1,parmrk=0" ;;
	esac
	case "$WUI_sel_com1_flow" in
		noflow) FLOWC="crtscts=0,ixon=0,ixoff=0" ;;
		xonxoff) FLOWC="crtscts=0,ixon=1,ixoff=1" ;;
		hw) FLOWC="crtscts=1,ixon=0,ixoff=0" ;;
	esac
	SSV_COM1_SOCAT="${SSV_G_MODDEV}0,b$WUI_sel_com1_bps,cs$WUI_sel_com1_bits,$PARITY,$STOPBITS,$FLOWC"
fi
if [ "x$WUI_sel_com2_app" = "xsocat" ]; then
	[ "x$WUI_sel_com2_stop" = "x1" ] && STOPBITS="cstopb=0" || STOPBITS="cstopb=1"
	case "$WUI_sel_com2_parity" in
		n) PARITY="parenb=0" ;;
		o) PARITY="parenb=1,parodd=1" ;;
		e) PARITY="parenb=1,parodd=0" ;;
		m) PARITY="parenb=1,parmrk=1" ;;
		s) PARITY="parenb=1,parmrk=0" ;;
	esac
	case "$WUI_sel_com2_flow" in
		noflow) FLOWC="crtscts=0,ixon=0,ixoff=0" ;;
		xonxoff) FLOWC="crtscts=0,ixon=1,ixoff=1" ;;
		hw) FLOWC="crtscts=1,ixon=0,ixoff=0" ;;
	esac
#	if [ "x$WUI_chk_com2_driver" = "xrs485" ]; then
#		DEV="/dev/ttyR1"
#		if [ ! -c $DEV ]; then
#			insmod /lib/modules/`uname -r`/extra/rs485.ko && \
#			mknod $DEV c 46 1
#		fi
#	else
#		DEV=${SSV_G_MODDEV}1
#	fi
	SSV_COM2_SOCAT="${SSV_G_MODDEV}1,b$WUI_sel_com2_bps,cs$WUI_sel_com2_bits,$PARITY,$STOPBITS,$FLOWC"
fi
if [ "x$WUI_sel_com3_app" = "xsocat" ]; then
	[ "x$WUI_sel_com3_stop" = "x1" ] && STOPBITS="cstopb=0" || STOPBITS="cstopb=1"
	case "$WUI_sel_com3_parity" in
		n) PARITY="parenb=0" ;;
		o) PARITY="parenb=1,parodd=1" ;;
		e) PARITY="parenb=1,parodd=0" ;;
		m) PARITY="parenb=1,parmrk=1" ;;
		s) PARITY="parenb=1,parmrk=0" ;;
	esac
	case "$WUI_sel_com3_flow" in
		noflow) FLOWC="crtscts=0,ixon=0,ixoff=0" ;;
		xonxoff) FLOWC="crtscts=0,ixon=1,ixoff=1" ;;
		hw) FLOWC="crtscts=1,ixon=0,ixoff=0" ;;
	esac
	SSV_COM3_SOCAT="${SSV_G_MODDEV}2,b$WUI_sel_com3_bps,cs$WUI_sel_com3_bits,$PARITY,$STOPBITS,$FLOWC"
fi

socatrun()
{
        test "x$1" = "xsocat" -a -n "$2" -a -n "$3" -a -n "$5" || return
        if [ "$4" = "client" ]; then
                # Client
                test -n "$6" || return
#                /etc/ssvconfig/bin/socat_wrapper "$3,raw,echo=0 $5:$6:$2" >/dev/null 2>/dev/null &
        else
                # Server defaults: keepcnt=9,keepidle=7200,keepintvl=75
                ssvconfig set fde_server.cfg WUI_chk_service off
                /etc/ssvconfig/init.d/fde_server.sh restart
                sleep 1
                if [ "$5" = "tcp4" ] ; then
                    extrapar="keepalive,keepidle=180,keepintvl=60"
                else
                    extrapar="reuseaddr,fork"
                fi
                /etc/ssvconfig/bin/socat_wrapper "$5-listen:$2,$extrapar $3,raw,echo=0" >/dev/null 2>/dev/null &
        fi
}

enable_modem()
{
	# Set Modem port
	rm -f /dev/modem
	if [ "x$WUI_sel_com3_app" = "xmodem" ]; then
		ln -s ${SSV_G_MODDEV}2 /dev/modem
	elif [ "x$WUI_sel_com2_app" = "xmodem" ]; then
		ln -s ${SSV_G_MODDEV}1 /dev/modem
	elif [ "x$WUI_sel_com1_app" = "xmodem" ]; then
		ln -s ${SSV_G_MODDEV}0 /dev/modem
	fi

	# Enable GPRS/UMTS-Modem
	if [ "x$WUI_sel_com3_app" = "xmodem" ]; then
		true # modem_on
	fi
}

disable_modem()
{
	# Disable GPRS-Modem
	if [ -e /dev/modem -a "x$WUI_sel_com3_app" != "xmodem" ]; then
		# modem_off
		rm -f /dev/modem
	fi
}

start()
{
#	enable_modem
        socatrun $WUI_sel_com1_app $WUI_com1_port $SSV_COM1_SOCAT $WUI_chk_com1_mode $WUI_sel_com1_proto $WUI_com1_ip
        socatrun $WUI_sel_com2_app $WUI_com2_port $SSV_COM2_SOCAT $WUI_chk_com2_mode $WUI_sel_com2_proto $WUI_com2_ip
        socatrun $WUI_sel_com3_app $WUI_com3_port $SSV_COM3_SOCAT $WUI_chk_com3_mode $WUI_sel_com3_proto $WUI_com3_ip
}

stop()
{
	killall socat_wrapper 2>/dev/null
	killall socat 2>/dev/null
#	disable_modem
}

configure()
{
#	ssv_tmpl2file comport.cfg inittab /etc
	:
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
	configure
#	kill -1 1
	start
	;;
    configure)
	configure
	;;
    *)
	echo "Usage: $0 {start|stop|restart|configure}"
	exit 1
esac

exit 0
