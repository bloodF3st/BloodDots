#!/bin/bash
# Close window, but hide Spotify to special workspace instead of killing it
active_class=$(hyprctl activewindow -j | jq -r '.class')

if [[ "$active_class" == "com.spotify.Client" ]]; then
    hyprctl dispatch movetoworkspacesilent special:spotify
else
    hyprctl dispatch killactive
fi
