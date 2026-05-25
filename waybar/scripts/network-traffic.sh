#!/bin/bash

interface=$(ip route | awk '/default/ {print $5; exit}')

[ -z "$interface" ] && {
    echo " Offline"
    exit 0
}

read -r rx_old < "/sys/class/net/$interface/statistics/rx_bytes"
read -r tx_old < "/sys/class/net/$interface/statistics/tx_bytes"

sleep 1

read -r rx_new < "/sys/class/net/$interface/statistics/rx_bytes"
read -r tx_new < "/sys/class/net/$interface/statistics/tx_bytes"

rx=$(( (rx_new - rx_old) / 1024 ))
tx=$(( (tx_new - tx_old) / 1024 ))

format_speed() {
    local speed=$1

    if (( speed < 1024 )); then
        printf "%dKB" "$speed"
    else
        printf "%.1fMB" "$(awk "BEGIN {print $speed/1024}")"
    fi
}

printf '{"text":" %s  %s"}\n' \
    "$(format_speed "$rx")" \
    "$(format_speed "$tx")"
