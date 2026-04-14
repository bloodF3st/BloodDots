#!/usr/bin/env bash
# Listen for AyuGram "Warning" dialog and force-resize it
SOCKET="/run/user/1000/hypr/$(ls /run/user/1000/hypr/)/.socket2.sock"

while true; do
    socat -U - UNIX-CONNECT:"$SOCKET" 2>/dev/null | while IFS= read -r line; do
        case "$line" in
            openwindowv2*)
                addr=$(echo "$line" | sed -n 's/^openwindowv2>>\([a-f0-9]*\),.*/\1/p')
                if [ -n "$addr" ]; then
                    sleep 0.3
                    is_warning=$(hyprctl -j clients 2>/dev/null | python3 -c "
import json, sys
for c in json.load(sys.stdin):
    if c['address'].replace('0x','') == '$addr'.replace('0x','') and c.get('title') == 'Warning':
        print('yes')
        break
" 2>/dev/null)
                    if [ "$is_warning" = "yes" ]; then
                        hyprctl dispatch resizeactive exact 400 300 address:0x$addr 2>/dev/null
                        hyprctl dispatch moveactive center address:0x$addr 2>/dev/null
                    fi
                fi
                ;;
        esac
    done
    sleep 1
done
