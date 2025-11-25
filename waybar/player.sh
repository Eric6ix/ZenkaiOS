# 1. Criar a pasta de scripts se não existir
mkdir -p ~/.config/waybar/scripts

# 2. Criar o arquivo do script
cat > ~/.config/waybar/scripts/player.sh << 'EOF'
#!/bin/bash

# Verificar players ativos
players=$(playerctl -l 2>/dev/null)

if [ -z "$players" ]; then
    echo '{"text":"","tooltip":"No media playing"}'
    exit 0
fi

# Prioridade de players
for player in spotify firefox chromium mpd; do
    if echo "$players" | grep -q "$player"; then
        selected_player=$player
        break
    fi
done

# Se não encontrou, usa o primeiro
if [ -z "$selected_player" ]; then
    selected_player=$(echo "$players" | head -1)
fi

# Obter metadados
status=$(playerctl -p "$selected_player" status 2>/dev/null)
artist=$(playerctl -p "$selected_player" metadata artist 2>/dev/null | sed 's/"/\\"/g')
title=$(playerctl -p "$selected_player" metadata title 2>/dev/null | sed 's/"/\\"/g')

if [ "$status" = "Playing" ]; then
    icon=""
    class="playing"
elif [ "$status" = "Paused" ]; then
    icon="" 
    class="paused"
else
    icon=""
    class="stopped"
fi

# Se não tem metadados, mostrar apenas o status
if [ -z "$title" ]; then
    text="$icon $status"
    tooltip="$selected_player: $status"
else
    # Limitar tamanho do texto
    if [ ${#title} -gt 25 ]; then
        title="${title:0:25}..."
    fi
    if [ -n "$artist" ]; then
        text="$icon ${artist:0:15} - $title"
        tooltip="$selected_player: ${artist} - ${title}"
    else
        text="$icon $title"
        tooltip="$selected_player: $title"
    fi
fi

echo "{\"text\":\"$text\",\"tooltip\":\"$tooltip\",\"class\":\"$class\"}"
EOF

# 3. Dar permissão de execução
chmod +x ~/.config/waybar/scripts/player.sh

# 4. Testar o script
bash ~/.config/waybar/scripts/player.sh