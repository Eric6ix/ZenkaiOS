#!/bin/bash

WALLDIR="$HOME/Wallpapers"
RANDOM_WALL=$(ls "$WALLDIR" | shuf -n 1)

hyprctl hyprpaper preload "$WALLDIR/$RANDOM_WALL"
hyprctl hyprpaper wallpaper ",$WALLDIR/$RANDOM_WALL"

