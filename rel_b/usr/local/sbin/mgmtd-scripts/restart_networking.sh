#!/bin/sh

# Restart networking to make certain changes take effect
logger -t mgmt "restart_networking started"
/etc/ssvconfig/init.d/network restart
logger -t mgmt "restart_networking done"
