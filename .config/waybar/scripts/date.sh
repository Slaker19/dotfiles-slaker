#!/bin/bash
d=$(date +%a)
case $d in
  Mon) d="Lun" ;; Tue) d="Mar" ;; Wed) d="Mié" ;; Thu) d="Jue" ;;
  Fri) d="Vie" ;; Sat) d="Sáb" ;; Sun) d="Dom" ;;
esac
cal=$(cal -y 2>/dev/null || echo "$(date +%Y) calendar unavailable")
python3 -c "
import json
d = '$d'
n = '$(date +%d)'
m = '$(date +%m)'
c = '''$cal'''
print(json.dumps({'text': f'  \uf073 {d} {n}/{m}', 'tooltip': c}))
"
