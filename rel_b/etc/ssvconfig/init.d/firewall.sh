#!/bin/sh

. /etc/ssvconfig/bin/ssvfunction
. /etc/ssvconfig/config/firewall.cfg

RULES="/etc/firewall.rules"
TMP_RULES="/tmp/ssvconfig/firewall.rules"
PID_FW="/var/run/firewall.pid"
PID_FILE="/var/run/firewall-watchdog.pid"

start()
{
	echo -n "Starting Firewall.........................................."
	rm -f $PID_FW
	if [ "x$WUI_chk_service" != "xon" ]; then
		logger -t firewall "Firewall is disabled by user config"
		echo "disabled"
	elif [ -f $RULES ]; then
		# Load modules for backward compatibility
		modprobe iptable_filter
		modprobe iptable_nat
		modprobe iptable_mangle
		modprobe ipt_MASQUERADE
		modprobe xt_conntrack
		modprobe xt_state

		if sh $RULES; then
			logger -t firewall "Firewall configured and enabled"
			echo $$ >$PID_FW
			echo "done"
		else
			logger -s -t firewall "Error: Firewall script"
			echo "failed"
		fi
	else
		logger -s -t firewall "Error: Missing script file! Firewall is disabled!"
		echo "failed"
	fi
}

stop()
{
	# Allow filters
	echo -n "Stopping Firewall.........................................."
	echo -e "*filter\n:INPUT ACCEPT [0:0]\n:FORWARD ACCEPT [0:0]\n:OUTPUT ACCEPT [0:0]\nCOMMIT" | iptables-restore
	# Remove MANGLE, used by IPsec
	echo -e "*mangle\n:POSTROUTING ACCEPT [0:0]\nCOMMIT" | iptables-restore
	# Remove NAT
	echo -e "*nat\n:PREROUTING ACCEPT [0:0]\n:POSTROUTING ACCEPT [0:0]\n:OUTPUT ACCEPT [0:0]\nCOMMIT" | iptables-restore
	echo "0" > /proc/sys/net/ipv4/ip_forward
	logger -t firewall "Firewall disabled"
	rm -f $PID_FW
	echo "done"
}

watchloop()
{
	logger -t fw-watch "start"
	trap "logger -t fw-watch \"ok done\"; exit 0" SIGTERM
	sleep 10
	if [ -f $PID_FILE ]; then
		rm -f $PID_FILE $RULES
		logger -t fw-watch "Timeout. Disable fw now!"
		stop
	fi
	logger -t fw-watch "end"
}

configure()
{
	# Skip this part for user uploaded script or disabled fw
	test "x$WUI_chk_service" != "xon" && return
	if [ "x$WUI_chk_mode" = "x9" ]; then
		logger -t firewall "Use rules from $WUI_user_script"
		[ -f /etc/firewall.rules.user ] && cp -a /etc/firewall.rules.user /etc/firewall.rules
		return
	fi

	test -z "$WUI_chk_mode" && WUI_chk_mode=1
	logger -t firewall "Create new script from set$WUI_chk_mode"

	if [ -f /etc/ssvconfig/config/modem ]; then
		. /etc/ssvconfig/config/modem
		if [ ! -z "$SSV_MODEM_TYPE" -a "x$SSV_MODEM_TYPE" != "xnone" ]; then
			export SSV_FIREWALL_WAN="ppp0"
		fi
	fi

	if [ -z "$SSV_FIREWALL_WAN" ]; then
		. /etc/ssvconfig/default/global
		export SSV_FIREWALL_WAN=$SSV_G_DSLDEV
	fi
	WAN=$SSV_FIREWALL_WAN
	
	cp -a /etc/ssvconfig/templates/firewall.rules.template $TMP_RULES.$$
	
	setr ""
	setr "# Keep state of connections from local machine and private subnets"
	setr "iptables -A OUTPUT -o $WAN -m state --state NEW -j ACCEPT"
	setr "iptables -A INPUT -i $WAN -m state --state ESTABLISHED,RELATED -j ACCEPT"
	setr ""
	setr "# Allow all incoming traffic per devices"
	setr "iptables -A INPUT -i lo -j ACCEPT"
	setr "iptables -A INPUT -i eth0 -j ACCEPT"
	setr "iptables -A INPUT -i br0 -j ACCEPT"
	
	# VPN
	if [ -f /etc/ssvconfig/config/openvpn ]; then
		. /etc/ssvconfig/config/openvpn
		if [ "$SSV_OPENVPN_ON" = "on" ]; then
			setr ""
			setr "# VPN"
			[ "$SSV_OPENVPN_SC" = "server" ] && \
			setr "iptables -A INPUT -p $SSV_OPENVPN_SERVER_PROTO -i $WAN --dport $SSV_OPENVPN_SERVER_PORT -j ACCEPT"
			# Allow TAP interface connections to OpenVPN server and the network behind eth0
			setr "iptables -A INPUT -i tap+ -j ACCEPT"
                        setr "iptables -A FORWARD -i tap+ -j ACCEPT"
                        setr "iptables -A FORWARD -o tap+ -j ACCEPT"
                        setr "iptables -A INPUT -i tun+ -j ACCEPT"
                        setr "iptables -A FORWARD -i tun+ -j ACCEPT"
                        setr "iptables -A FORWARD -o tun+ -j ACCEPT"
			if [ "$SSV_OPENVPN_FW_ON" = "on" ]; then
				# Add VPN-client specific rules
				setr "[ ! -s /etc/fw-tap.rules ] || sh /etc/fw-tap.rules"
			fi
		fi
	fi
	
	# IPsec
	if [ -f /etc/ssvconfig/config/ipsec ]; then
		. /etc/ssvconfig/config/ipsec
		if [ "$SSV_IPSEC_ON" = "on" ]; then
			setr ""
			setr "# IPsec"
			[ "$SSV_IPSEC_PROTO" = "esp" ] && setr "iptables -A INPUT -p esp -i $WAN -j ACCEPT"
			if [ "$SSV_IPSEC_PROTO" = "natt" -a "$SSV_IPSEC_SC" = "server" ]; then
				setr "iptables -A INPUT -p udp -i $WAN --dport 500 -j ACCEPT"
				setr "iptables -A INPUT -p udp -i $WAN --dport 4500 -j ACCEPT"
			fi
			
			# IPsec Subnet routing
			if [ "$WUI_chk_masq" = "on" ]; then
				setr "modprobe iptable_mangle"
				setr "modprobe xt_mark"
				setr "modprobe xt_MARK"
				[ "$SSV_IPSEC_PROTO" = "esp" ] && setr "iptables -A PREROUTING -t mangle -p esp -i $WAN -j MARK --set-mark 1"
				[ "$SSV_IPSEC_PROTO" = "natt" ] && setr "iptables -A PREROUTING -t mangle -p udp --dport 4500 -i $WAN -j MARK --set-mark 1"
				setr "iptables -A FORWARD -i $WAN -m mark --mark 1 -j ACCEPT"
				setr "iptables -A POSTROUTING -t nat -d $SSV_IPSEC_LEFTSUBNET -j RETURN"
			fi
		fi
	fi

	# Masquerade local subnet
	if [ "$WUI_chk_masq" = "on" ]; then
		setr ""
		setr "# Masquerade local subnet"
		setr "iptables -A POSTROUTING -t nat -o $WAN -j MASQUERADE"
		setr "iptables -A FORWARD -i eth0 -o $WAN -m state --state NEW -j ACCEPT"
		setr "iptables -A FORWARD -i br0 -o $WAN -m state --state NEW -j ACCEPT"
		setr "iptables -A FORWARD -m state --state ESTABLISHED,RELATED -j ACCEPT"
		setr "echo 1 > /proc/sys/net/ipv4/ip_forward"
	fi
	
	if [ "$WUI_chk_mode" = "2" ]; then
	# SSH
	if [ "$WUI_chk_rule_ssh" = "on" -a -f /etc/ssvconfig/config/openssh.cfg ]; then
		. /etc/ssvconfig/config/openssh.cfg
		if [ "$WUI_chk_service" = "on" ]; then
			setr ""
			setr "# SSH"
			setr "iptables -A INPUT -p tcp -i $WAN --dport $WUI_ssh_port -j ACCEPT"
		fi
	fi
	
	# Telnet
	if [ "$WUI_chk_rule_telnet" = "on" ]; then
		setr ""
		setr "# Telnet"
		setr "iptables -A INPUT -p tcp -i $WAN --dport 23 -j ACCEPT"
	fi
	
	# http
	if [ "$WUI_chk_rule_http" = "on" ]; then
		setr ""
		setr "# HTTP"
		setr "iptables -A INPUT -p tcp -i $WAN --dport 80 -j ACCEPT"
	fi
	
	# https
	if [ "$WUI_chk_rule_https" = "on" ]; then
		setr ""
		setr "# HTTPS"
		setr "iptables -A INPUT -p tcp -i $WAN --dport 443 -j ACCEPT"
	fi
	
	# Webproxy
	if [ "$WUI_chk_rule_webproxy" = "on" -a -f /etc/ssvconfig/config/proxy ]; then
		. /etc/ssvconfig/config/proxy
		setr ""
		setr "# Webproxy"
		test -z "$SSV_PROXY_INPORT0" || setr "iptables -A INPUT -p tcp -i $WAN --dport $SSV_PROXY_INPORT0 -j ACCEPT"
		test -z "$SSV_PROXY_INPORT1" || setr "iptables -A INPUT -p tcp -i $WAN --dport $SSV_PROXY_INPORT1 -j ACCEPT"
		test -z "$SSV_PROXY_INPORT2" || setr "iptables -A INPUT -p tcp -i $WAN --dport $SSV_PROXY_INPORT2 -j ACCEPT"
		test -z "$SSV_PROXY_INPORT3" || setr "iptables -A INPUT -p tcp -i $WAN --dport $SSV_PROXY_INPORT3 -j ACCEPT"
		test -z "$SSV_PROXY_INPORT4" || setr "iptables -A INPUT -p tcp -i $WAN --dport $SSV_PROXY_INPORT4 -j ACCEPT"
		test -z "$SSV_PROXY_INPORT5" || setr "iptables -A INPUT -p tcp -i $WAN --dport $SSV_PROXY_INPORT5 -j ACCEPT"
		test -z "$SSV_PROXY_INPORT6" || setr "iptables -A INPUT -p tcp -i $WAN --dport $SSV_PROXY_INPORT6 -j ACCEPT"
		test -z "$SSV_PROXY_INPORT7" || setr "iptables -A INPUT -p tcp -i $WAN --dport $SSV_PROXY_INPORT7 -j ACCEPT"
		test -z "$SSV_PROXY_INPORT8" || setr "iptables -A INPUT -p tcp -i $WAN --dport $SSV_PROXY_INPORT8 -j ACCEPT"
		test -z "$SSV_PROXY_INPORT9" || setr "iptables -A INPUT -p tcp -i $WAN --dport $SSV_PROXY_INPORT9 -j ACCEPT"
	fi
	
	# FTPproxy
	if [ "$WUI_chk_rule_ftpproxy" = "on" -a -f /etc/ssvconfig/config/ftpproxy ]; then
		. /etc/ssvconfig/config/ftpproxy
		setr ""
		setr "# FTPproxy"
		test -z "$SSV_FTPPROXY_INPORT0" || setr "iptables -A INPUT -p tcp -i $WAN --dport $SSV_FTPPROXY_INPORT0 -j ACCEPT"
		test -z "$SSV_FTPPROXY_INPORT1" || setr "iptables -A INPUT -p tcp -i $WAN --dport $SSV_FTPPROXY_INPORT1 -j ACCEPT"
		test -z "$SSV_FTPPROXY_INPORT2" || setr "iptables -A INPUT -p tcp -i $WAN --dport $SSV_FTPPROXY_INPORT2 -j ACCEPT"
		test -z "$SSV_FTPPROXY_INPORT3" || setr "iptables -A INPUT -p tcp -i $WAN --dport $SSV_FTPPROXY_INPORT3 -j ACCEPT"
		test -z "$SSV_FTPPROXY_INPORT4" || setr "iptables -A INPUT -p tcp -i $WAN --dport $SSV_FTPPROXY_INPORT4 -j ACCEPT"
		test -z "$SSV_FTPPROXY_INPORT5" || setr "iptables -A INPUT -p tcp -i $WAN --dport $SSV_FTPPROXY_INPORT5 -j ACCEPT"
		test -z "$SSV_FTPPROXY_INPORT6" || setr "iptables -A INPUT -p tcp -i $WAN --dport $SSV_FTPPROXY_INPORT6 -j ACCEPT"
		test -z "$SSV_FTPPROXY_INPORT7" || setr "iptables -A INPUT -p tcp -i $WAN --dport $SSV_FTPPROXY_INPORT7 -j ACCEPT"
		test -z "$SSV_FTPPROXY_INPORT8" || setr "iptables -A INPUT -p tcp -i $WAN --dport $SSV_FTPPROXY_INPORT8 -j ACCEPT"
		test -z "$SSV_FTPPROXY_INPORT9" || setr "iptables -A INPUT -p tcp -i $WAN --dport $SSV_FTPPROXY_INPORT9 -j ACCEPT"
	fi
	
	# TCPproxy
	if [ "$WUI_chk_rule_tcpproxy" = "on" -a -f /etc/ssvconfig/config/telproxy ]; then
		. /etc/ssvconfig/config/telproxy
		setr ""
		setr "# TCPproxy"
		test -z "$SSV_TELPROXY_INPORT0" || setr "iptables -A INPUT -p tcp -i $WAN --dport $SSV_TELPROXY_INPORT0 -j ACCEPT"
		test -z "$SSV_TELPROXY_INPORT1" || setr "iptables -A INPUT -p tcp -i $WAN --dport $SSV_TELPROXY_INPORT1 -j ACCEPT"
		test -z "$SSV_TELPROXY_INPORT2" || setr "iptables -A INPUT -p tcp -i $WAN --dport $SSV_TELPROXY_INPORT2 -j ACCEPT"
		test -z "$SSV_TELPROXY_INPORT3" || setr "iptables -A INPUT -p tcp -i $WAN --dport $SSV_TELPROXY_INPORT3 -j ACCEPT"
		test -z "$SSV_TELPROXY_INPORT4" || setr "iptables -A INPUT -p tcp -i $WAN --dport $SSV_TELPROXY_INPORT4 -j ACCEPT"
		test -z "$SSV_TELPROXY_INPORT5" || setr "iptables -A INPUT -p tcp -i $WAN --dport $SSV_TELPROXY_INPORT5 -j ACCEPT"
		test -z "$SSV_TELPROXY_INPORT6" || setr "iptables -A INPUT -p tcp -i $WAN --dport $SSV_TELPROXY_INPORT6 -j ACCEPT"
		test -z "$SSV_TELPROXY_INPORT7" || setr "iptables -A INPUT -p tcp -i $WAN --dport $SSV_TELPROXY_INPORT7 -j ACCEPT"
		test -z "$SSV_TELPROXY_INPORT8" || setr "iptables -A INPUT -p tcp -i $WAN --dport $SSV_TELPROXY_INPORT8 -j ACCEPT"
		test -z "$SSV_TELPROXY_INPORT9" || setr "iptables -A INPUT -p tcp -i $WAN --dport $SSV_TELPROXY_INPORT9 -j ACCEPT"
		test -z "$SSV_TELPROXY_INPORT10" || setr "iptables -A INPUT -p tcp -i $WAN --dport $SSV_TELPROXY_INPORT10 -j ACCEPT"
		test -z "$SSV_TELPROXY_INPORT11" || setr "iptables -A INPUT -p tcp -i $WAN --dport $SSV_TELPROXY_INPORT11 -j ACCEPT"
		test -z "$SSV_TELPROXY_INPORT12" || setr "iptables -A INPUT -p tcp -i $WAN --dport $SSV_TELPROXY_INPORT12 -j ACCEPT"
		test -z "$SSV_TELPROXY_INPORT13" || setr "iptables -A INPUT -p tcp -i $WAN --dport $SSV_TELPROXY_INPORT13 -j ACCEPT"
		test -z "$SSV_TELPROXY_INPORT14" || setr "iptables -A INPUT -p tcp -i $WAN --dport $SSV_TELPROXY_INPORT14 -j ACCEPT"
		test -z "$SSV_TELPROXY_INPORT15" || setr "iptables -A INPUT -p tcp -i $WAN --dport $SSV_TELPROXY_INPORT15 -j ACCEPT"
		test -z "$SSV_TELPROXY_INPORT16" || setr "iptables -A INPUT -p tcp -i $WAN --dport $SSV_TELPROXY_INPORT16 -j ACCEPT"
		test -z "$SSV_TELPROXY_INPORT17" || setr "iptables -A INPUT -p tcp -i $WAN --dport $SSV_TELPROXY_INPORT17 -j ACCEPT"
		test -z "$SSV_TELPROXY_INPORT18" || setr "iptables -A INPUT -p tcp -i $WAN --dport $SSV_TELPROXY_INPORT18 -j ACCEPT"
		test -z "$SSV_TELPROXY_INPORT19" || setr "iptables -A INPUT -p tcp -i $WAN --dport $SSV_TELPROXY_INPORT19 -j ACCEPT"
	fi
	
	# WebConfig
	if [ "$WUI_chk_rule_webui" = "on" -a -f /etc/ssvconfig/config/webconfig.cfg ]; then
		. /etc/ssvconfig/config/webconfig.cfg
		setr ""
		setr "# WebConfig"
		setr "iptables -A INPUT -p tcp -i $WAN --dport $WUI_chk_service -j ACCEPT"
	fi
	
	# ICMP Ping
	if [ "$WUI_chk_rule_icmp" = "on" ]; then
		setr ""
		setr "# Allow incoming pings"
		setr "iptables -A INPUT -p icmp --icmp-type echo-request -j ACCEPT"
	fi
	
	# User specific
	setr ""
	setr "# User specific"
	if [ "$WUI_chk_rule_user1" = "on" ]; then
		setr "iptables -A INPUT -p $WUI_chk_user1_proto -i $WAN --dport $WUI_user1_port -j ACCEPT"
	fi
	if [ "$WUI_chk_rule_user2" = "on" ]; then
		setr "iptables -A INPUT -p $WUI_chk_user2_proto -i $WAN --dport $WUI_user2_port -j ACCEPT"
	fi
	if [ "$WUI_chk_rule_user3" = "on" ]; then	
		setr "iptables -A INPUT -p $WUI_chk_user3_proto -i $WAN --dport $WUI_user3_port -j ACCEPT"
	fi
	if [ "$WUI_chk_rule_user4" = "on" ]; then	
		setr "iptables -A INPUT -p $WUI_chk_user4_proto -i $WAN --dport $WUI_user4_port -j ACCEPT"
	fi
	if [ "$WUI_chk_rule_user5" = "on" ]; then	
		setr "iptables -A INPUT -p $WUI_chk_user5_proto -i $WAN --dport $WUI_user5_port -j ACCEPT"
	fi
	fi
	
	MD1=`md5sum $TMP_RULES.$$ | cut -b1-32`
	MD2=`md5sum $RULES | cut -b1-32`
	if [ "$MD1" = "$MD2" ]; then
		rm -f $TMP_RULES.$$
		return
	fi
	mv $TMP_RULES.$$ $RULES
}

setr(){
	echo $1 >>$TMP_RULES.$$
}
case "$1" in
	start)
		start
	;;
	stop)
		stop
	;;
	restart)
		test "x$WUI_chk_service" = "xon" || stop
		configure
		start
	;;
	configure)
		configure
	;;
	watchdog+)
		watchloop >/dev/null 2>/dev/null </dev/null &
		echo "$!" >$PID_FILE
	;;
	watchdog-)
		kill -TERM `cat $PID_FILE` >/dev/null 2>/dev/null
		rm -f $PID_FILE >/dev/null 2>/dev/null
	;;
	policies)
		iptables -L -v
		L=`iptables -t nat -L 2>/dev/null | wc -l`
		if [ $L != 0 -a $L != 8 ]; then
			echo
			echo "=== NAT Policies ==="
			iptables -t nat -L -v
		fi
		L=`iptables -t mangle -L 2>/dev/null | wc -l`
		if [ $L != 0 -a $L != 14 ]; then
			echo
			echo "=== MANGLE Policies ==="
			iptables -t mangle -L -v
		fi
	;;
	upload)
	    logger "firewall.sh upload"
	    if [ -f /tmp/webgui/upload/firewall.rules.user ]; then
		cp -a /tmp/webgui/upload/firewall.rules.user /etc/firewall.rules.user.$$
		mv /etc/firewall.rules.user.$$ /etc/firewall.rules.user
		rm -f /tmp/webgui/upload/firewall.rules.user
	    fi
	;;
	*)
	echo "Usage: $0 {start|stop|restart|configure|watchdog[+|-]|policies|upload}"
	exit 1
esac

exit 0
