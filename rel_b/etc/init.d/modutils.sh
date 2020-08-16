#!/bin/sh
#
# modutils      This script install modules on start given by modullist 
#               in /etc/modules
#
# Version:      1.00  01.03.2009  ene@SSV, based on original
#

[ -s /etc/modules ] || exit 0

. /etc/init.d/functions

KLEVEL="$(cat /proc/sys/kernel/printk)"
echo 1 > /proc/sys/kernel/printk
g_echo -n "Loading modules:"

(cat /etc/modules; echo; ) | 
while read module args; do
    if [ -f "/lib/modules/$module" ]; then
        g_echo -n "$module+"
	insmod /lib/modules/$module $args >/dev/null 2>/dev/null
    fi    
done

g_echo -e "done"
echo ${KLEVEL} > /proc/sys/kernel/printk

: exit 0
