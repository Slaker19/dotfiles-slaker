#!/usr/bin/env bash
cliphist list | rofi -dmenu -p "Clipboard" -config ~/.config/rofi/cliphist-config.rasi | cliphist decode | wl-copy
