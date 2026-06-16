#!/usr/bin/env bash
DIR=${1:-up}
STEP=${2:-5}

case "$DIR" in
  up)
    brightnessctl s "${STEP}%+"
    ;;
  down)
    CUR=$(brightnessctl g)
    MAX=$(brightnessctl m)
    PCT=$((CUR * 100 / MAX))
    [ "$PCT" -gt "$STEP" ] && brightnessctl s "${STEP}%-"
    ;;
esac

CUR=$(brightnessctl g)
MAX=$(brightnessctl m)
PCT=$((CUR * 100 / MAX))
notify-send -h int:value:"$PCT" "Brightness" "${PCT}%" -t 1000 -i display-brightness