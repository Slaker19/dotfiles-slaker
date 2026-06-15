#!/usr/bin/env bash
case "$1" in
  lock)   loginctl lock-session ;;
  logout) wlogout ;;
  sleep)  systemctl suspend ;;
  reboot) systemctl reboot ;;
  shutdown) systemctl poweroff ;;
  *)
    echo "{\"text\": \"⏻\", \"tooltip\": \"Power Menu\"}"
    ;;
esac
