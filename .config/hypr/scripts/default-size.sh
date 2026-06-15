#!/usr/bin/env bash
WIN=$(hyprctl activewindow -j)
if [ "$(echo "$WIN" | jq -r '.floating')" = "true" ]; then
  hyprctl dispatch togglefloating
  exit
fi

hyprctl dispatch togglefloating

WIN=$(hyprctl activewindow -j)
CW=$(echo "$WIN" | jq -r '.size[0]')
CH=$(echo "$WIN" | jq -r '.size[1]')
DW=$((800 - CW))
DH=$((600 - CH))

hyprctl dispatch resizeactive $DW $DH
hyprctl dispatch centerwindow
