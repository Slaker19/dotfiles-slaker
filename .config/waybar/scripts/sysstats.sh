#!/bin/bash
cpu=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d. -f1)
mem=$(free -h | awk '/^Mem/ {print $3}' | sed 's/Gi/GB/')
temp=$(sensors | grep 'Package id' | awk '{print $4}' | tr -d '+')
disk=$(df -h / | awk 'NR==2 {print $5}')

printf '{"text":"  \uf4bc %s%%  \uf2db %s  \uf2c9 %s  \uf0a0 %s"}\n' "$cpu" "$mem" "$temp" "$disk"
