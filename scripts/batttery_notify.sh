#!/bin/bash

# battery_notify.sh

LOW=20
CRITICAL=10

while true; do
  capacity=$(upower -i /org/freedesktop/UPower/devices/battery_BAT0 | grep percentage | awk '{print $2}' | tr -d '%')
  status=$(upower -i /org/freedesktop/UPower/devices/battery_BAT0 | grep state | awk '{print $2}')

  if [[ "$status" == "discharging" && "$capacity" -le "$LOW" && "$capacity" -gt "$CRITICAL" ]]; then
    notify-send "⚡ Bateria baixa" "Nível: ${capacity}% — conecte o carregador." -u normal
  elif [[ "$status" == "discharging" && "$capacity" -le "$CRITICAL" ]]; then
    notify-send "❗ Bateria crítica" "Nível: ${capacity}% — salve seu trabalho!" -u critical
  elif [[ "$status" == "charging" ]]; then
    notify-send "🔌 Carregando" "A bateria está sendo carregada (nível ${capacity}%)" -u low
  fi

  sleep 120  # checa a cada 2 minutos
done
