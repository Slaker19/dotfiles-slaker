#!/usr/bin/env bash
STATUS=$(playerctl status 2>/dev/null) || { echo '{"text":"","class":"empty"}'; exit 0; }
case "$STATUS" in
  Playing) echo '{"text":"\u25b6","class":"playing"}' ;;
  Paused) echo '{"text":"\u23f8","class":"paused"}' ;;
  *) echo '{"text":"","class":"empty"}' ;;
esac
