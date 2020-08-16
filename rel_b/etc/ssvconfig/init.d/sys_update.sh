#! /bin/sh
#
# Description:  download and upload system configuration
# Version:      3.01  21.09.2009  ene@SSV
#

. /etc/ssvconfig/bin/ssvfunction
. /etc/ssvconfig/config/system.cfg

# this both directoris and package name are compiled in into cgi's
WUI_UPLOAD_DIR=/tmp/webgui/upload
WUI_FW_PACKAGE=firmware.bin
WUI_SH_PACKAGE=firmware.sh
WUI_FW_STAT=/var/run/sys_update.stat

set_stat() {
    echo -e "$1\n$2" > $WUI_FW_STAT.$$
    mv $WUI_FW_STAT.$$ $WUI_FW_STAT
}

#states
#0 running
#1 done
#2,3 error
update() {
	cd $WUI_UPLOAD_DIR
	if [ -f $WUI_FW_STAT ]; then
	    case "$(head -n1 $WUI_FW_STAT)" in
		0,1) 	exit 0 
			;;
		2) 	;;
		*)	exit 0
			;;
	    esac
	fi
	set_stat "0" "Checking firmware signature ..."

	rm -f $WUI_SH_PACKAGE 2>/dev/null
	gpg --homedir /etc/gpg/ --no-default-keyring --always-trust -o $WUI_SH_PACKAGE -d $WUI_FW_PACKAGE
	if [ $? -ne 0 ]; then
		set_stat "2" "Check firmware signature failed!"
		rm -f $WUI_FW_PACKAGE 2>/dev/null
		rm -f $WUI_SH_PACKAGE 2>/dev/null
		exit 1
	fi
	
	set_stat "0" "Installing firmware ..."
	rm -f $WUI_FW_PACKAGE 2>/dev/null
	echo "y" | sh $WUI_SH_PACKAGE
	if [ $? -ne 0 ]; then 
		set_stat "3" "Firmware update failed! System will now reboot."
		ssv_logger 3 "Firmware update failed! System will now reboot."
	else
		set_stat "1" "Firmware updated! System will now reboot."
    		ssv_logger 7 "Firmware updated! System will now reboot."
	fi
	sleep 3
	exec /sbin/reboot
	exit 0
}

state(){
	echo $WUI_FW_STAT
	return 0
}

case "$1" in
    update)
	update
    ;;
    state)
	state
    ;;
    upload)
	;;
    *)
	echo "Usage: $0 {update|state}"
	exit 1
esac

exit 0
