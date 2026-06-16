#!/usr/bin/env bash
MIN=5
CUR=$(brightnessctl g)
MAX=$(brightnessctl m)
PCT=$((CUR * 100 / MAX))
[ "$PCT" -gt "$MIN" ] && brightnessctl s 5%-
