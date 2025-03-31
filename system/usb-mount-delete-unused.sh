#!/bin/bash
# FLSUN S1 Open Source Edition

for dir in /home/pi/printer_data/gcodes/*/ ; do
    if [ -d "$dir" ] && [ -z "$(ls -A "$dir")" ] && ! mountpoint -q "$dir" && [[ $(basename "$dir") == USB-DISK-* ]]; then
        echo "Deleting unsused usb-mount directory: $dir"
        rmdir "$dir"
    fi
done
