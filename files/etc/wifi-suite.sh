#!/bin/sh

echo "Associated wifi stations' AKM suites:"
cd /var/run/hostapd
for socket in *; do
  [ -S "$socket" ] || continue
  [ "$socket" = "global" ] && continue
  for assoc in $(hostapd_cli -i "$socket" list_sta); do
    suite=$(hostapd_cli -i "$socket" sta "$assoc" | grep "AKMSuiteSelector" | cut -f 2 -d"=")
    case "$suite" in
        00-0f-ac-1) akm=802.1x  ;;
        00-0f-ac-2) akm=WPA-PSK  ;;
        00-0f-ac-3) akm=FT-802.1x  ;;
        00-0f-ac-4) akm=WPA-PSK-FT  ;;
        00-0f-ac-5) akm=802.1x-SHA256  ;;
        00-0f-ac-6) akm=WPA-PSK-SHA256  ;;
        00-0f-ac-7) akm=TDLS  ;;
        00-0f-ac-8) akm=WPA3-SAE  ;;
        00-0f-ac-9) akm=FT-SAE  ;;
        00-0f-ac-10) akm=AP-PEER-KEY  ;;
        00-0f-ac-11) akm=802.1x-suite-B  ;;
        00-0f-ac-12) akm=802.1x-suite-B-192  ;;
        00-0f-ac-13) akm=FT-802.1x-SHA384  ;;
        00-0f-ac-14) akm=FILS-SHA256  ;;
        00-0f-ac-15) akm=FILS-SHA384  ;;
        00-0f-ac-16) akm=FT-FILS-SHA256  ;;
        00-0f-ac-17) akm=FT-FILS-SHA384  ;;
        00-0f-ac-18) akm=OWE  ;;
        00-0f-ac-19) akm=FT-WPA2-PSK-SHA384  ;;
        00-0f-ac-20) akm=WPA2-PSK-SHA384  ;;
        *) akm="undefined" ;;
    esac
    echo "$socket: AKM suite of $assoc is $suite ($akm)"
  done
done

