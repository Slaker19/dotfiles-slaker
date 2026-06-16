#!/usr/bin/env bash
set -euo pipefail

WALLPAPER_PATH="${1:-}"
REL_X="${2:-0.5}"
REL_Y="${3:-0.5}"

if [[ -z "$WALLPAPER_PATH" ]]; then
  echo "usage: $0 <wallpaper_path> [rel_x] [rel_y]" >&2
  exit 1
fi

pkill -f "mpvpaper" 2>/dev/null || true

case "$WALLPAPER_PATH" in
  *.mp4|*.webm|*.mov|*.avi|*.mkv|*.MP4|*.WEBM|*.MOV|*.AVI|*.MKV)
    MONITOR=$(hyprctl monitors -j | jq -r '.[0].name' 2>/dev/null || echo "eDP-1")
    mpvpaper -f -o "no-audio loop" "$MONITOR" "$WALLPAPER_PATH" &>/dev/null &
    ;;
  *)
    if command -v awww >/dev/null 2>&1; then
      awww img "$WALLPAPER_PATH" \
        --transition-type grow \
        --transition-pos "$REL_X,$REL_Y" \
        --transition-step 30 \
        --transition-duration 1.2 \
        --transition-fps 60
    fi
    ;;
esac

mkdir -p "$HOME/.cache/wallpicker"
ln -sfn "$WALLPAPER_PATH" "$HOME/.cache/wallpicker/current_wallpaper.png"

CURRENT_LINK="$HOME/.config/rofi/.current_wallpaper"
ln -sf "$WALLPAPER_PATH" "$CURRENT_LINK"

HYPRPAPER_CONF="$HOME/.config/hypr/hyprpaper.conf"
MONITOR=$(hyprctl monitors -j | jq -r '.[0].name' 2>/dev/null || echo "eDP-1")
cat > "$HYPRPAPER_CONF" << CONFEOF
preload = $WALLPAPER_PATH
wallpaper = ,$WALLPAPER_PATH
wallpaper = $MONITOR,$WALLPAPER_PATH
CONFEOF
