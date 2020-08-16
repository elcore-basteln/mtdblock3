#!/bin/sh
#
# Description:    sys_logging
# Version:        3.01  21.09.2009  ene@SSV
#
FILE=$1
[ -f $1 ] || FILE=/var/log/syslog/messages
grep "" $FILE | tail -n32
exit 0
