#!/bin/sh

# Special parameters
logger -t mgmt "set_parm $1"
if [ "$1" = "reboot" ]
then
	( sleep 5; init 6; )&
fi
