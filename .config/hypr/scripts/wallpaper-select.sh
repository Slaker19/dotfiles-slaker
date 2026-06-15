#!/usr/bin/env bash
WALLPAPER_DIR="$HOME/Wallpapers"
HYPRPAPER_CONF="$HOME/.config/hypr/hyprpaper.conf"
CURRENT_LINK="$HOME/.config/rofi/.current_wallpaper"

wall=$(hyprwat --wallpaper "$WALLPAPER_DIR")

if [ -z "$wall" ]; then
  exit 0
fi

pkill -f "mpvpaper" 2>/dev/null

case "$wall" in
  *.mp4|*.webm|*.mov|*.avi|*.mkv|*.MP4|*.WEBM|*.MOV|*.AVI|*.MKV)
    MONITOR=$(hyprctl monitors -j | jq -r '.[0].name' 2>/dev/null || echo "eDP-1")
    mpvpaper -f -o "no-audio loop" "$MONITOR" "$wall" &>/dev/null &
    notify-send "Wallpaper" "Video: $(basename "$wall")"
    ;;
  *)
    awww img "$wall" --transition-fps 60 --transition-type grow --transition-duration 2 --transition-pos 0.5,0.5 2>/dev/null
    notify-send "Wallpaper" "$(basename "$wall")"
    ;;
esac

ln -sf "$wall" "$CURRENT_LINK"

cat > "$HYPRPAPER_CONF" << CONFEOF
preload = $wall
wallpaper = ,$wall
wallpaper = $(hyprctl monitors -j | jq -r '.[0].name' 2>/dev/null || echo "eDP-1"),$wall
CONFEOF
