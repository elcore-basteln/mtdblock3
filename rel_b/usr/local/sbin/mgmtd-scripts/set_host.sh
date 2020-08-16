#!/bin/sh

logger -t mgmt "set_host $1"
ssvconfig set system.cfg WUI_hostname $1
hostname $1
