#!/usr/bin/env bash

PLAYERCTL=$(command -v playerctl)
STATUS=$($PLAYERCTL status 2>/dev/null)

if [ -z "$STATUS" ]; then
  echo '{"text":"","class":"empty"}'
  exit 0
fi

ARTIST=$($PLAYERCTL metadata artist 2>/dev/null)
TITLE=$($PLAYERCTL metadata title 2>/dev/null)

if [ -z "$TITLE" ]; then
  echo '{"text":"","class":"empty"}'
  exit 0
fi

if [ "$STATUS" = "Playing" ]; then
  ICON="\uf14b"
elif [ "$STATUS" = "Paused" ]; then
  ICON="\uf14c"
else
  echo '{"text":"","class":"empty"}'
  exit 0
fi

if [ -n "$ARTIST" ]; then
  TEXT="$ICON $ARTIST - $TITLE"
else
  TEXT="$ICON $TITLE"
fi

echo "{\"text\":\"$TEXT\",\"class\":\"$STATUS\"}"
