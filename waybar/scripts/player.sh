#!/bin/bash

players=$(playerctl -l 2>/dev/null)

[ -z "$players" ] && {
    echo '{"text":" No Player","tooltip":"No media playing","class":"stopped"}'
    exit 0
}

# Escolher player prioritário
selected_player=$(
    for p in spotify firefox chromium mpd; do
        grep -qx "$p" <<< "$players" && {
            echo "$p"
            break
        }
    done
)

selected_player=${selected_player:-$(head -n1 <<< "$players")}

# Buscar tudo em menos chamadas
status=$(playerctl -p "$selected_player" status 2>/dev/null)

artist=$(playerctl -p "$selected_player" metadata artist 2>/dev/null)
title=$(playerctl -p "$selected_player" metadata title 2>/dev/null)

# Escapar JSON
artist=${artist//\"/\\\"}
title=${title//\"/\\\"}

case "$status" in
    Playing)
        icon=""
        class="playing"
        ;;
    Paused)
        icon=""
        class="paused"
        ;;
    *)
        icon=""
        class="stopped"
        ;;
esac

short_title="${title:0:25}"
[ ${#title} -gt 25 ] && short_title+="..."

short_artist="${artist:0:15}"

if [ -z "$title" ]; then
    text="$icon $status"
    tooltip="$selected_player: $status"

elif [ -n "$artist" ]; then
    text="$icon ♪ $short_title"
    tooltip="$selected_player: $artist - $title"

else
    text="$icon $short_title"
    tooltip="$selected_player: $title"
fi

printf '{"text":"%s","tooltip":"%s","class":"%s"}\n' \
    "$text" "$tooltip" "$class"
