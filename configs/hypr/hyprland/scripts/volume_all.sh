#!/bin/bash
# Change volume on ALL sinks simultaneously using pactl IDs
# Usage: volume_all.sh up|down [step%]
DIRECTION="${1:-up}"
STEP="${2:-2%}"

pactl list sinks short | awk '{print $1}' | while read -r id; do
    if [ "$DIRECTION" = "up" ]; then
        pactl set-sink-volume "$id" "+${STEP}"
    else
        pactl set-sink-volume "$id" "-${STEP}"
    fi
done
