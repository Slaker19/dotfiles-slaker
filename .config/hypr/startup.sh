#!/usr/bin/env bash
# Autostart applications for Hyprland
echo "Launching Waybar..."
waybar &

echo "Launching SwayNC..."
swaync &

echo "Launching Quickshell..."
quickshell &
