#!/bin/bash
# FLSUN S1 Open Source Edition

rm -f /tmp/calibration_data_*.csv
if [ -d "/home/pi/printer_data/config/Resonances Graphics" ]; then
  rm -rf "/home/pi/printer_data/config/Resonances Graphics"
fi
exit 0
