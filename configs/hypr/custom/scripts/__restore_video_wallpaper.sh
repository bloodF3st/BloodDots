#!/bin/bash
# Video wallpaper via mpvpaper
# Видео 5120x1440 разрезается на два монитора 1920x1080:
#   HDMI-A-2 (левый,  at 0x0)    — левая  половина
#   DP-1     (правый, at 1920x0) — правая половина

VIDEO="$HOME/Pictures/wallpapers/video/sakura-falls.mp4"

pkill -x mpvpaper 2>/dev/null
sleep 0.3

# Левый монитор — кроп левой половины (scale до 3840x1080, crop 1920:1080 с x=0)
mpvpaper -o "no-audio loop vf=lavfi=[scale=3840:1080,crop=1920:1080:0:0]" \
    HDMI-A-2 "$VIDEO" &

# Правый монитор — кроп правой половины (scale до 3840x1080, crop 1920:1080 с x=1920)
mpvpaper -o "no-audio loop vf=lavfi=[scale=3840:1080,crop=1920:1080:1920:0]" \
    DP-1 "$VIDEO" &
