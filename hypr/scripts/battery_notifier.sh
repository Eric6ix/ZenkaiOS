#!/bin/bash

# Configurações
LOW_BATTERY=20
CRITICAL_BATTERY=10
FULL_BATTERY=95
CHECK_INTERVAL=30  # segundos

# Cores e estilo
COLOR_NORMAL="#89B4FA"
COLOR_WARNING="#F9E2AF"
COLOR_CRITICAL="#F38BA8"
COLOR_FULL="#A6E3A1"

# Função para enviar notificação
send_battery_notification() {
    local level="$1"
    local status="$2"
    local urgency="$3"
    local color="$4"
    
    # Mensagens baseadas no nível
    case $level in
        "CRITICAL")
            message="Bateria CRÍTICA: ${CRITICAL_BATTERY}% ou menos!\nConecte o carregador IMEDIATAMENTE!"
            icon="❌"
            ;;
        "LOW")
            message="Bateria baixa: ${LOW_BATTERY}%\nConecte o carregador em breve."
            icon="⚠️"
            ;;
        "FULL")
            message="Bateria carregada: ${FULL_BATTERY}%\nPode desconectar o carregador."
            icon="🔌"
            ;;
        "CHARGING")
            message="Bateria carregando: $status%\n$status% ↯ Conectado"
            icon="⚡"
            ;;
        "DISCHARGING")
            message="Bateria descarregando: $status%\n$status% ↘ Desconectado"
            icon="🔋"
            ;;
    esac
    
    notify-send \
        -u "$urgency" \
        -t 10000 \
        -h "string:fgcolor:#FFFFFF" \
        -h "string:bgcolor:#1E1E2E" \
        -h "string:frcolor:$color" \
        "$icon Status da Bateria" "$message"
}

# Função principal de monitoramento
monitor_battery() {
    local last_level=0
    local last_status=""
    local low_notified=false
    local critical_notified=false
    local full_notified=false
    
    echo "🔋 Iniciando monitoramento de bateria..."
    echo "📊 Limites: Baixa=$LOW_BATTERY% | Crítica=$CRITICAL_BATTERY% | Cheia=$FULL_BATTERY%"
    
    while true; do
        # Obtém status atual da bateria
        local battery_path=$(find /sys/class/power_supply/ -name "BAT*" | head -1)
        local capacity=$(cat "$battery_path/capacity" 2>/dev/null)
        local status=$(cat "$battery_path/status" 2>/dev/null)
        
        if [[ -z "$capacity" || -z "$status" ]]; then
            sleep $CHECK_INTERVAL
            continue
        fi
        
        # Notificações baseadas no status e nível
        case $status in
            "Discharging")
                # Bateria descarregando - verificar níveis baixos
                if [[ $capacity -le $CRITICAL_BATTERY ]] && [[ $critical_notified == false ]]; then
                    send_battery_notification "CRITICAL" "$capacity" "critical" "$COLOR_CRITICAL"
                    critical_notified=true
                    low_notified=true
                elif [[ $capacity -le $LOW_BATTERY ]] && [[ $low_notified == false ]]; then
                    send_battery_notification "LOW" "$capacity" "normal" "$COLOR_WARNING"
                    low_notified=true
                elif [[ $capacity -gt $LOW_BATTERY ]]; then
                    # Reset das notificações quando carregar acima do nível baixo
                    low_notified=false
                    critical_notified=false
                fi
                ;;
                
            "Charging")
                # Bateria carregando - notificar quando estiver cheia
                if [[ $capacity -ge $FULL_BATTERY ]] && [[ $full_notified == false ]]; then
                    send_battery_notification "FULL" "$capacity" "low" "$COLOR_FULL"
                    full_notified=true
                elif [[ $capacity -lt $FULL_BATTERY ]]; then
                    full_notified=false
                fi
                
                # Notificar quando começar a carregar (apenas se mudou de status)
                if [[ "$last_status" != "Charging" ]]; then
                    send_battery_notification "CHARGING" "$capacity" "low" "$COLOR_NORMAL"
                fi
                ;;
                
            "Full")
                # Bateria completamente carregada
                if [[ $full_notified == false ]]; then
                    send_battery_notification "FULL" "$capacity" "low" "$COLOR_FULL"
                    full_notified=true
                fi
                ;;
        esac
        
        # Notificar mudança significativa de nível (apenas para debugging)
        # if [[ $(($last_level - $capacity)) -ge 10 ]] || [[ $(($capacity - $last_level)) -ge 10 ]]; then
        #     send_battery_notification "DISCHARGING" "$capacity" "low" "$COLOR_NORMAL"
        # fi
        
        last_level=$capacity
        last_status=$status
        sleep $CHECK_INTERVAL
    done
}

# Iniciar monitoramento
monitor_battery
