#!/bin/bash
# FLSUN S1 Open Source Edition

SCREENSHOTS_FOLDER="/home/pi/printer_data/config/screenshots"
mkdir -p "$SCREENSHOTS_FOLDER"

LATEST_NUM=$(find "$SCREENSHOTS_FOLDER" -maxdepth 1 -type f -name 'screenshot_*.png' |
             sed -E 's/.*screenshot_([0-9]+)\.png/\1/' | sort -nr | head -1)

if [[ -z "$LATEST_NUM" || ! "$LATEST_NUM" =~ ^[0-9]+$ ]]; then
    NEXT_NUM=1
else
    NEXT_NUM=$((10#$LATEST_NUM + 1))
fi

FILENAME=$(printf "%s/screenshot_%03d.png" "$SCREENSHOTS_FOLDER" "$NEXT_NUM")

ffmpeg -f x11grab -i :0.0 -frames:v 1 -update 1 "$FILENAME" -y
