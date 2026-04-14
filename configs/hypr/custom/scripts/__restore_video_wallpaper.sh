#!/bin/bash
# Video wallpaper via mpvpaper
# 5120x1440 panorama split across two 1920x1080 monitors:
#   HDMI-A-2 (left,  at 0x0)    — left half
#   DP-1     (right, at 1920x0) — right half

VIDEO="$HOME/Pictures/wallpapers/video/sakura-falls.mp4"

pkill -x mpvpaper 2>/dev/null
sleep 0.3

mpvpaper -o "no-audio loop vf=lavfi=[scale=3840:1080,crop=1920:1080:0:0]" \
    HDMI-A-2 "$VIDEO" &

mpvpaper -o "no-audio loop vf=lavfi=[scale=3840:1080,crop=1920:1080:1920:0]" \
    DP-1 "$VIDEO" &
