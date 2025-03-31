#!/bin/bash
# FLSUN S1 Open Source Edition

if ! ls /tmp/calibration_data_x_*.csv /tmp/calibration_data_y_*.csv 1> /dev/null 2>&1; then
  echo "Error: No resonance data files found! Please start the CALIBRATION_RESONANCES macro first."
  exit 1
fi

if [ ! -d "/home/pi/printer_data/config/Resonances Graphics" ]; then
	mkdir -p "/home/pi/printer_data/config/Resonances Graphics"
fi
/home/pi/klipper/scripts/calibrate_shaper.py /tmp/calibration_data_x_*.csv -o "/home/pi/printer_data/config/Resonances Graphics/resonances_x.png" && /home/pi/klipper/scripts/calibrate_shaper.py /tmp/calibration_data_y_*.csv -o "/home/pi/printer_data/config/Resonances Graphics/resonances_y.png"

echo
echo "Graphics are now available in config folder."

exit 0
