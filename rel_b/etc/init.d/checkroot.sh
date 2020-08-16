#!/bin/sh
#
# checkroot     Check and remount root filesystem.
#
# Version:      1.00  01.03.2009  ene@SSV
#

. /etc/init.d/functions

rootmode=ro
rootcheck="yes"
#
# Check the root filesystem.
#
if [ "$rootcheck" = yes ]; then
    # Ensure that root is quiescent and read-only before fsck'ing.
    g_echo -n "Checking root filesystem..................................."
    mount -n -o remount,ro / 
    if [ $? -eq 0 ]; then
	fsck.ext3 -p / >/dev/null 2>/dev/null
	RTC=$?
	if [ "$RTC" -eq 1 ]; then
	    fsck.ext3 -p / >/dev/null 2>/dev/null
	elif [ "$RTC" -gt 1 ]; then
	    g_echo "failed"
	    reboot -f
	fi    
	# NOTE: "failure" is defined as exiting with a return code of
	# 2 or larger.  A return code of 1 indicates that filesystem
	# errors were corrected but that the boot may proceed.
	g_echo "done"
    else
	g_echo "failed: rootfs is rw"
    fi
fi

#
# Remount the root filesystem.
#

if [ x$(grep "^rootfs" /proc/mounts | awk '{print $4}') != "x$rootmode" ]; then
    g_echo -n "Remounting root file system................................"
    mount -n -o remount,$rootmode /
    g_echo "done"
fi

: exit 0
