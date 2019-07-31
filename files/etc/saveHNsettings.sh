#!/bin/sh
cd /etc
tar -czv -f /tmp/HNsettings \
  config/network config/wireless config/firewall config/dhcp config/sqm \
  config/luci_statistics config/bcp38 \
  dropbear/authorized_keys adblock/adblock.whitelist
if [ "$?" -eq 0 ] ; then
  ccencrypt -vf /tmp/HNsettings
  if [ "$?" -eq 0 ] ; then
    cp -f /tmp/HNsettings.cpt /etc/HNsettings.$1.cpt
  fi
fi

