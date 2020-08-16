#!/bin/sh
#

#mkdir -p /dev/rootfs
#mount -t jffs2 /dev/mtdblock2 /dev/rootfs -o ro

FW_ACT_REL=rel_a
[ -f /flash/rel_b/active ] && FW_ACT_REL=rel_b 
export FW_ACT_REL
exec /flash/$FW_ACT_REL/etc/ssvconfig/init.d/ssvinit.sh start
