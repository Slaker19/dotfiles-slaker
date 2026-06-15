#!/usr/bin/env bash
# Simple weather using wttr.in
CACHE_FILE="/tmp/waybar-weather.cache"
CACHE_MAX=1800
NOW=$(date +%s)
if [ -f "$CACHE_FILE" ]; then
  MTIME=$(stat -c %Y "$CACHE_FILE")
  DIFF=$((NOW - MTIME))
  [ $DIFF -lt $CACHE_MAX ] && cat "$CACHE_FILE" && exit 0
fi
DATA=$(curl -s "wttr.in/?format=%C+%t&u" 2>/dev/null)
[ -z "$DATA" ] && DATA="N/A"
echo "$DATA" > "$CACHE_FILE"
echo "$DATA"
