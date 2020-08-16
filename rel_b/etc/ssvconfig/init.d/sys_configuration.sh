#! /bin/sh
#
# Description:  download and upload system configuration
# Version:      3.01  21.09.2009  ene@SSV
#

. /etc/ssvconfig/bin/ssvfunction
. /etc/ssvconfig/config/system.cfg

#S3CMD_BIN=/usr/bin/s3cmd
#CURL_BIN="curl --retry 3 --silent --show-error --fail"
#AMI_INSTANCE_URL="http://169.254.169.254/2009-04-04"

# this both directoris and package name are compiled in into cgi's
WUI_DOWNLOAD_DIR=/tmp/webgui/download
WUI_UPLOAD_DIR=/tmp/webgui/upload
WUI_CONFIG_PACKAGE=device_config.tgz

# define here what files or directoris should be saved into package to download
WUI_CONFIG_FILES="
/etc/ssvconfig/config
/etc/fde
/etc/lighttpd
$(find /etc/ssh -type f 2>/dev/null | grep -vE 'moduli|\.old')
$(find /etc/ssl -type f | grep -vE 'openssl\.conf|\.old|\.rnd')
$(find /etc/openvpn -type f | grep -vE 'easy-rsa')
/etc/firewall.*
/etc/inetd.*
/etc/network/interfaces*
/etc/passwd
/etc/inittab
/etc/crontab
/etc/hostname
/etc/dyndns.conf
/etc/udhcpd.conf
/etc/ipsec.*
/etc/proxy-suite
/etc/pound.cfg
/etc/totd.conf
/etc/udhcpd.conf
/etc/ppp/peers 
/etc/ppp/chat-* 
/etc/ppp/*-secrets 
/etc/ppp/options
"

createConfigPackage(){
    mkdir -p $WUI_DOWNLOAD_DIR
	tar -czf $WUI_DOWNLOAD_DIR/$WUI_CONFIG_PACKAGE.$$ $WUI_CONFIG_FILES
    mv -f $WUI_DOWNLOAD_DIR/$WUI_CONFIG_PACKAGE.$$ $WUI_DOWNLOAD_DIR/$WUI_CONFIG_PACKAGE
    if [ $? -ne 0 ]; then
        ssv_logger 3 "failed to create $WUI_CONFIG_PACKAGE config package."
        return 12
    fi
    ssv_logger 7 "config package $WUI_CONFIG_PACKAGE successful created."
    rm -f $WUI_DOWNLOAD_DIR/$WUI_CONFIG_PACKAGE.$$
    return 0
}

extractConfigPackage(){
    if [ -f $WUI_UPLOAD_DIR/$WUI_CONFIG_PACKAGE ]; then
        if ! tar xzf $WUI_UPLOAD_DIR/$WUI_CONFIG_PACKAGE -C /; then
            rm -f $WUI_UPLOAD_DIR/$WUI_CONFIG_PACKAGE
            ssv_logger 3 "failed to extract $WUI_CONFIG_PACKAGE config package. File corrupt."
            return 10
        fi
        rm -f $WUI_UPLOAD_DIR/$WUI_CONFIG_PACKAGE
        ssv_logger 7 "config package $WUI_CONFIG_PACKAGE successful extracted."
    else
        ssv_logger 3 "failed to extract $WUI_CONFIG_PACKAGE config package. File not found."
        return 11
    fi
    return 0
}

uploadConfigPackage(){
    #if [ -f /etc/s3cmd.conf ]; then 
    #   ssv_tmpl2file s3account.cfg s3cmd.conf /etc
    #fi 
    #$S3CMD_BIN \
	--config=/etc/s3cmd.conf \
	--bucket-location=$WUI_sel_s3_bucket_location \
	--force \
	--acl-private \
	put $WUI_DOWNLOAD_DIR/$WUI_CONFIG_PACKAGE s3://$WUI_s3_bucket_name/$WUI_CONFIG_PACKAGE >/dev/null 2>/dev/null
    #if [ $? -ne 0 ]; then
	#ssv_logger 1 "Failed to upload $WUI_CONFIG_PACKAGE config package to s3://$WUI_s3_bucket_name"
	#return 13
    #fi
    #ssv_logger 0 "Config package $WUI_CONFIG_PACKAGE successful uploaded to s3://$WUI_s3_bucket_name"
    return 0
}

downloadConfigPackage(){
    #restore configuration from s3
    #parameter $2=buket name, $2=bucket location
    #if [ -n "$1" -a -n "$2" ]; then
    #    ssv_logger 0 "Download package $WUI_CONFIG_PACKAGE from s3://$1"
    #    mkdir -p $WUI_UPLOAD_DIR
    #    $S3CMD_BIN \
        --config=/etc/s3cmd.conf \
        --bucket-location=$2 \
        --force \
        get s3://$1/$WUI_CONFIG_PACKAGE $WUI_UPLOAD_DIR/$WUI_CONFIG_PACKAGE >/dev/null 2>/dev/null
    #    if [ -s $WUI_UPLOAD_DIR/$WUI_CONFIG_PACKAGE ]; then
    #        ssv_logger 0 "Downloaded package $WUI_CONFIG_PACKAGE from s3://$1"
            return 0
    #    fi
    #fi
    #ssv_logger 1 "Failed download package $WUI_CONFIG_PACKAGE from s3://$1"
    #return 14
}

start(){
    mkdir -p $WUI_UPLOAD_DIR
    #perl -MIO::Socket::INET -e 'until(new IO::Socket::INET("169.254.169.254:80")){print"Waiting for network...\n";sleep 1}' | logger -t system
    #if [ -z "$WUI_s3_bucket_name" -o -z "$WUI_sel_s3_bucket_location" ]; then
    #    AMI_USER_DATA=$($CURL_BIN $AMI_INSTANCE_URL/user-data)
    #    set -- $(echo $AMI_USER_DATA | awk -F";" '{print $1,$2,$3,$4}')
    #    if [ -z "$1" -o -z "$2" -o -z "$3" -o -z "$4" ]; then
    #        ssv_logger 1 "No user-data parameters given. Can not load configuration."
    #        exit 1
    #    else
    #        ssv_logger 0 "Loading config with userdata: Acc:$1 Key:... Bucket:$3 Loc:$4"
    #    fi
    #    $WUI_BIN_DIR/s3account.sh configure
    #    downloadConfigPackage "$3" "$4"
    #    extractConfigPackage
    #    ssv_load_config system.cfg
    #    if [ -z "$WUI_s3_bucket_name" -o -z "$WUI_sel_s3_bucket_location" ]; then
    #        cat $WUI_CONFIG_DIR/system.cfg | grep -v "WUI_s3_bucket_name\|WUI_sel_s3_bucket_location" > $WUI_CONFIG_DIR/system.cfg.$$
    #        echo "WUI_s3_bucket_name='$3'" >> $WUI_CONFIG_DIR/system.cfg.$$
    #        echo "WUI_sel_s3_bucket_location='$4'" >> $WUI_CONFIG_DIR/system.cfg.$$
    #        mv -f $WUI_CONFIG_DIR/system.cfg.$$ $WUI_CONFIG_DIR/system.cfg
    #    fi
    #fi
}



case "$1" in
    store)
	createConfigPackage
	uploadConfigPackage
	exit $?
    ;;
    stop)
	#if [ "x$WUI_chk_s3_autostore" = "xon" ]; then
	#    createConfigPackage
	#    uploadConfigPackage
	#fi
	#exit $?
    ;;
    start)
	start
    ;;
    restore)
	#[ -f /etc/s3cmd.conf ] || ssv_tmpl2file s3account.cfg s3cmd.conf /etc
	#downloadConfigPackage "$WUI_s3_bucket_name" "$WUI_sel_s3_bucket_location"
	extractConfigPackage
	exit $?
	;;
    restart)
	;;
    configure)
	;;
    download)
	createConfigPackage
	exit $?
	;;
    upload)
	extractConfigPackage
	exit $?
	;;
    *)
	echo "Usage: $0 {stop|start|restart|configure|download|upload|store|restore}"
	exit 1
esac

exit 0
