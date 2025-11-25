#!/bin/bash

interface=$(ip route | grep default | awk '{print $5}' | head -1)

if [ -z "$interface" ]; then
    echo " Offline"
    exit 0
fi

# Obter dados da interface
rx_old=$(cat /sys/class/net/$interface/statistics/rx_bytes)
tx_old=$(cat /sys/class/net/$interface/statistics/tx_bytes)

sleep 1

rx_new=$(cat /sys/class/net/$interface/statistics/rx_bytes)
tx_new=$(cat /sys/class/net/$interface/statistics/tx_bytes)

# Calcular velocidade em KB/s
rx_speed=$(( (rx_new - rx_old) / 1024 ))
tx_speed=$(( (tx_new - tx_old) / 1024 ))

# Formatar saída
if [ $rx_speed -lt 1024 ]; then
    rx_display="${rx_speed}KB"
else
    rx_display=$(echo "scale=1; $rx_speed/1024" | bc)MB
fi

if [ $tx_speed -lt 1024 ]; then
    tx_display="${tx_speed}KB"
else
    tx_display=$(echo "scale=1; $tx_speed/1024" | bc)MB
fi

echo " $rx_display  $tx_display"