#!/bin/sh
/etc/init.d/collectd stop
cd /tmp/rrd/$(uname -n)
logger -t "LuCI statistics" collectd stopped, create backup archive
tar c -zvf /etc/backup.stats/stats.tar.gz *
cp /etc/backup.stats/stats.tar.gz /etc/backup.stats/stats-$(date +%Y%m%dT%H%M).tar.gz
/etc/init.d/collectd start
