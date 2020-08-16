#!/bin/sh
#
# mountall      Mount/umount local filesystems in /etc/fstab.
#
# Version:      1.0  09.03.2009  ene@SSV
#

. /etc/init.d/functions

case "$1" in
    start)
        g_echo -n "Mounting local filesystems................................."
	mount -a >/dev/null 2>/dev/null
	g_echo "done"
	;;
    stop)
	g_echo -n "Unmounting local filesystems..............................."
	(cat /etc/fstab; echo; ) |
	while read fs mnt type opts dump pass junk; do
	    case "$fs" in
    		""|\#*)
    		    continue;
    		    ;;
		*)
    		    umount -f -r ${mnt} >/dev/null 2>/dev/null
    		    ;;
	    esac
	done
	g_echo "done"
        ;;
    *)
        echo "Usage: $0 {start|stop}" >&2
        exit 1
        ;;
esac
										    
exit 0
