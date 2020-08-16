//================ hier menu eintraege bearbeiten bzw zufuegen =================
var title="Elcore2400 CSG";
//==============================================================================
// +-------- verwendungshilfe -------------+
// | standard menulink     : "name:link"   |
// | aufklabbares menufeld : "name:#"      |
// | ein untermenulink     : "-name:link"  |
// +---------------------------------------+
var menus = new Array(
    "Status:status.cgi",
    "System:#",
        "-Identification:sys_identification.cgi",
        "-Management:sys_management.cgi",
        "-Configuration:sys_configuration.cgi",
        "-Firmware update:sys_update.cgi",
	"-Time and date:time.cgi",
        "-COM ports:comport.cgi",
        "-Logging:sys_logging.cgi",
    "Network:#",
        "-LAN:network.cgi",
/*        "-Modem:modem_cfg.cgi",*/
    "Services:#",
        "-General:services.cgi",
        "-OpenVPN:openvpn_cfg.cgi",
/*        "-DynDNS:dyndns_cfg.cgi",*/
/*	  "-Keepalive:keepalive_cfg.cgi",*/
/*        "-DHCP server:dhcpd_cfg.cgi",*/
/*        "-Firewall and NAT:firewall.cgi",*/
        "-Remote access:openssh.cgi",
        "-WebConfig:webconfig.cgi",
/*    "Proxies:#",*/
/*        "-Web:webproxy_cfg.cgi",*/
/*        "-DNS:dnsproxy_cfg.cgi",*/
/*        "-Filetransfer:ftpproxy_cfg.cgi",*/
/*        "-Telnet/SSH/others:telproxy_cfg.cgi",*/
    "Field Data Engine:#",
        "-Devices:fde_server.cgi",
/*        "-WebView:fde_webview.cgi",*/
        "-Portal:fde_mqtt.cgi"
);
//==============================================================================
