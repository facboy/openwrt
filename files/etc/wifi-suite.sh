#!/bin/sh
# Copyright 2021-2023 Hannu Nyman
# Modified 2026-02-08 - Re-integrated full cipher list and robust SSID fix
# SPDX-License-Identifier: GPL-2.0-only

if [ ! -d "/var/run/hostapd" ]; then
    echo "Error: /var/run/hostapd directory not found. Is hostapd running?"
    exit 1
fi

if ! command -v hostapd_cli >/dev/null 2>&1; then
    echo "Error: hostapd_cli command not found."
    exit 1
fi

echo "WI-FI STATION DETAILS BY INTERFACE"

cd /var/run/hostapd || exit 1

for socket in *; do
    [ -S "$socket" ] || continue
    [ "$socket" = "global" ] && continue

    # SSID-Extraktion
    ssid=$(hostapd_cli -i "$socket" get_config 2>/dev/null | grep "^ssid=" | cut -d'=' -f2-)

    # Frequency - Fallback-SSID
    if_status=$(hostapd_cli -i "$socket" status)
    [ -z "$ssid" ] && ssid=$(echo "$if_status" | sed -n 's/^ssid=//p' | head -n1)
    freq=$(echo "$if_status" | sed -n 's/^freq=//p' | head -n1)

    printf "\nIF: %s | SSID: %s | Freq: %sMHz\n" "$socket" "$ssid" "${freq:-unknown}"

    # Connected stations
    stations=$(hostapd_cli -i "$socket" list_sta)
    if [ -z "$stations" ]; then
        echo "  (No stations connected)"
        continue
    fi

    for assoc in $stations; do
        sta_info=$(hostapd_cli -i "$socket" sta "$assoc")

        # Raw data
        suite=$(echo "$sta_info" | grep "AKMSuiteSelector" | cut -f 2 -d"=")
        wpa_ver=$(echo "$sta_info" | grep "^wpa=" | cut -f 2 -d"=")
        cipher_hex=$(echo "$sta_info" | grep "dot11RSNAStatsSelectedPairwiseCipher" | cut -f 2 -d"=")

        # 1. WLAN-Generation
        if echo "$sta_info" | grep -qiE "EHT-CAP|EHT_CAP"; then bw="Wi-Fi 7"
        elif echo "$sta_info" | grep -qiE "HE-CAP|HE_CAP"; then bw="Wi-Fi 6"
        elif echo "$sta_info" | grep -qiE "VHT-CAP|VHT_CAP"; then bw="Wi-Fi 5"
        elif echo "$sta_info" | grep -qiE "HT-CAP|HT_CAP"; then bw="Wi-Fi 4"
        else bw="Legacy"; fi

        # 2. Protocol
        case "$suite" in
            00-0f-ac-8|00-0f-ac-9|00-0f-ac-11|00-0f-ac-12|00-0f-ac-13|\
            00-0f-ac-14|00-0f-ac-15|00-0f-ac-16|00-0f-ac-17|00-0f-ac-18|\
            00-0f-ac-19|00-0f-ac-20)
                wpa_proto="WPA3" ;;
            *) [ "$wpa_ver" = "2" ] && wpa_proto="WPA2" || wpa_proto="WPA/Leg" ;;
        esac

        # 3. AKM
        case "$suite" in
            00-0f-ac-1) akm="802.1x" ;;
            00-0f-ac-2) akm="PSK" ;;
            00-0f-ac-3) akm="802.1x-FT" ;;
            00-0f-ac-4) akm="PSK-FT" ;;
            00-0f-ac-5) akm="802.1x-SHA256" ;;
            00-0f-ac-6) akm="PSK-SHA256" ;;
            00-0f-ac-7) akm="TDLS" ;;
            00-0f-ac-8) akm="SAE" ;;
            00-0f-ac-9) akm="SAE-FT" ;;
            00-0f-ac-10) akm="AP-PEER-KEY" ;;
            00-0f-ac-11) akm="802.1x-suite-B" ;;
            00-0f-ac-12) akm="802.1x-suite-B-192" ;;
            00-0f-ac-13) akm="802.1x-FT-SHA384" ;;
            00-0f-ac-14) akm="FILS-SHA256" ;;
            00-0f-ac-15) akm="FILS-SHA384" ;;
            00-0f-ac-16) akm="FILS-FT-SHA256" ;;
            00-0f-ac-17) akm="FILS-FT-SHA384" ;;
            00-0f-ac-18) akm="OWE" ;;
            00-0f-ac-19) akm="WPA2-PSK-FT-SHA384" ;;
            00-0f-ac-20) akm="WPA2-PSK-SHA384" ;;
            *) akm="Other" ;;
        esac

        # 4. Cipher
        case "$cipher_hex" in
            00-0f-ac-1) cipher="WEP40" ;;
            00-0f-ac-2) cipher="TKIP" ;;
            00-0f-ac-4) cipher="CCMP-128 (AES)" ;;
            00-0f-ac-5) cipher="WEP104" ;;
            00-0f-ac-6) cipher="CMAC" ;;
            00-0f-ac-8) cipher="GCMP-128" ;;
            00-0f-ac-9) cipher="GCMP-256" ;;
            00-0f-ac-10) cipher="CCMP-256" ;;
            00-0f-ac-11) cipher="GMAC-128" ;;
            00-0f-ac-12) cipher="GMAC-256" ;;
            00-0f-ac-13) cipher="CMAC-256" ;;
            *) cipher="$cipher_hex Unknown" ;;
        esac

        printf "  STA: %-18s | %-8s | %-4s %-8s | Cipher: %-10s\n" \
               "$assoc" "$bw" "$wpa_proto" "$akm" "$cipher"
    done
done

