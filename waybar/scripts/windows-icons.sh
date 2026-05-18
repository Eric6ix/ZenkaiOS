#!/usr/bin/env bash

clients=$(hyprctl clients -j)

echo "$clients" | jq -r '
.[]
| select(.mapped == true)
| "\(.address) \(.class)"
' | while read -r addr class; do
    icon=$(grep -ril "Icon=.*$class" /usr/share/applications 2>/dev/null \
        | head -n1 \
        | xargs -r grep -i "^Icon=" \
        | head -n1 \
        | cut -d= -f2)

    printf '{"text":"<span size=\"large\">%s</span>","tooltip":"%s","class":"win","address":"%s"}\n' "$icon" "$class" "$addr"
done | jq -s '{text: (map(.text) | join("  ")), tooltip: (map(.tooltip) | join("\n"))}'
