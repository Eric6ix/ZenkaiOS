#!/bin/bash

SCRIPT_DIR="$HOME/.config/hypr/scripts"
PID_FILE="$SCRIPT_DIR/battery_notifier.pid"
LOG_FILE="$SCRIPT_DIR/battery_notifier.log"

case "$1" in
    "start")
        if [[ -f "$PID_FILE" ]]; then
            pid=$(cat "$PID_FILE")
            if kill -0 "$pid" 2>/dev/null; then
                echo "✅ Monitor de bateria já está rodando (PID: $pid)"
                exit 0
            else
                rm -f "$PID_FILE"
            fi
        fi
        
        nohup "$SCRIPT_DIR/battery_notifier.sh" >> "$LOG_FILE" 2>&1 &
        echo $! > "$PID_FILE"
        echo "✅ Monitor de bateria iniciado (PID: $!)"
        ;;
        
    "stop")
        if [[ -f "$PID_FILE" ]]; then
            pid=$(cat "$PID_FILE")
            kill "$pid" 2>/dev/null
            rm -f "$PID_FILE"
            echo "✅ Monitor de bateria parado"
        else
            echo "❌ Monitor de bateria não está rodando"
        fi
        ;;
        
    "status")
        if [[ -f "$PID_FILE" ]]; then
            pid=$(cat "$PID_FILE")
            if kill -0 "$pid" 2>/dev/null; then
                echo "✅ Monitor de bateria rodando (PID: $pid)"
                tail -5 "$LOG_FILE" 2>/dev/null
            else
                echo "❌ Monitor de bateria não está rodando"
                rm -f "$PID_FILE"
            fi
        else
            echo "❌ Monitor de bateria não está rodando"
        fi
        ;;
        
    "restart")
        "$0" stop
        sleep 2
        "$0" start
        ;;
        
    "log")
        if [[ -f "$LOG_FILE" ]]; then
            tail -20 "$LOG_FILE"
        else
            echo "Arquivo de log não encontrado: $LOG_FILE"
        fi
        ;;
        
    *)
        echo "Uso: $0 {start|stop|status|restart|log}"
        echo ""
        echo "Exemplos:"
        echo "  $0 start    - Inicia o monitoramento"
        echo "  $0 stop     - Para o monitoramento" 
        echo "  $0 status   - Mostra status do monitor"
        echo "  $0 restart  - Reinicia o monitoramento"
        echo "  $0 log      - Mostra últimas linhas do log"
        ;;
esac
