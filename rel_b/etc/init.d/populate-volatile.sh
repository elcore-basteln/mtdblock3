#!/bin/sh

mkdir -p /var/volatile/cache /var/volatile/cron/tabs /var/volatile/lock /var/volatile/log/syslog /var/volatile/run /var/volatile/tmp /var/lock/subsys
chmod 1777 /var/volatile/lock /var/volatile/tmp

touch /var/log/wtmp /var/run/utmp /var/run/resolv.conf
chmod 0664 /var/log/wtmp /var/run/utmp

exit 0
