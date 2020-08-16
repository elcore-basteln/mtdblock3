#!/bin/sh
#
# sysfs         This script mount proc and sys filesystem
#
# Version:      1.00  01.03.2009  ene@SSV
#

. /etc/init.d/functions

if [ -e /proc ] && ! [ -e /proc/mounts ]; then
    mount -t proc proc /proc
fi

if [ -e /sys ] && grep -q sysfs /proc/filesystems; then
    g_echo -n "Mounting sys filesystem...................................."
    mount sysfs /sys -t sysfs
    g_echo "done"
fi

exit 0
