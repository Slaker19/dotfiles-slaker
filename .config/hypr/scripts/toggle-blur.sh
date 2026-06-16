#!/usr/bin/env bash
STATE_FILE=/tmp/hypr-blur-state

if [ -f "$STATE_FILE" ]; then
    rm "$STATE_FILE"
    hyprctl keyword decoration:active_opacity 0.96
    hyprctl keyword decoration:inactive_opacity 0.90
    hyprctl keyword decoration:blur:enabled true
    notify-send "Blur/Transparency" "ON" -t 1000
else
    touch "$STATE_FILE"
    hyprctl keyword decoration:active_opacity 1.0
    hyprctl keyword decoration:inactive_opacity 1.0
    hyprctl keyword decoration:blur:enabled false
    notify-send "Blur/Transparency" "OFF" -t 1000
fi
