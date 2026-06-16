#!/usr/bin/env bash
DIR=${1:-up}
STEP=${2:-5}

case "$DIR" in
  up)
    pactl set-sink-volume @DEFAULT_SINK@ "+${STEP}%"
    ;;
  down)
    pactl set-sink-volume @DEFAULT_SINK@ "-${STEP}%"
    ;;
  mute)
    pactl set-sink-mute @DEFAULT_SINK@ toggle
    ;;
esac

MUTED=$(pactl get-sink-mute @DEFAULT_SINK@ | awk '{print $2}')
VOL=$(pactl get-sink-volume @DEFAULT_SINK@ | head -1 | awk '{print $5}' | tr -d '%')

if [[ "$MUTED" == "yes" ]]; then
  notify-send -h int:value:0 "Volume" "Muted" -t 1000 -i audio-volume-muted
else
  notify-send -h int:value:"$VOL" "Volume" "${VOL}%" -t 1000 -i audio-volume-high
fi