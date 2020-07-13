#!/bin/sh
/etc/init.d/collectd stop
cd /tmp/rrd/$(uname -n)
logger -t "LuCI statistics" collectd stopped, create backup archive
tar c -zvf /etc/backup.stats/stats.tar.gz *
/etc/init.d/collectd start
