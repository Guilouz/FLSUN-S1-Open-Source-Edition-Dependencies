#!/bin/bash
# FLSUN S1 Open Source Edition

CONFIG_DIR="/home/pi/printer_data/config"

edit_config() {
  local action="$1"
  local item="$2"
  local file="$3"
  "/home/pi/flsun-os/installer/scripts/edit-config.py" "$action" "$item" "$file"
}

# Fan Upgrade Kit (CPAP less noisy) or S1 Pro
setup1_yes() {
    edit_config disable "include Configurations/fan-stock.cfg" config > /dev/null 2>&1
    edit_config enable "include Configurations/fan-silent-kit.cfg" config > /dev/null 2>&1
}

setup1_no() {
    edit_config enable "include Configurations/fan-stock.cfg" config > /dev/null 2>&1
    edit_config disable "include Configurations/fan-silent-kit.cfg" config > /dev/null 2>&1
}

# Control Camera settings with macros
setup2_yes() {
    edit_config enable "include Configurations/camera-control.cfg" config > /dev/null 2>&1
}

setup2_no() {
    edit_config disable "include Configurations/camera-control.cfg" config > /dev/null 2>&1
}

# Timelapse feature
setup3_yes() {
    edit_config enable "include timelapse.cfg" config > /dev/null 2>&1
    edit_config enable "timelapse" moonraker > /dev/null 2>&1
    edit_config enable "update_manager Timelapse" moonraker > /dev/null 2>&1
    ln -srfn "/home/pi/moonraker-timelapse/klipper_macro/timelapse.cfg" "$CONFIG_DIR/timelapse.cfg" > /dev/null 2>&1
}

setup3_no() {
    edit_config disable "include timelapse.cfg" config > /dev/null 2>&1
    edit_config disable "timelapse" moonraker > /dev/null 2>&1
    edit_config disable "update_manager Timelapse" moonraker > /dev/null 2>&1
    if [ -f "$CONFIG_DIR/timelapse.cfg" ]; then
        rm -f "$CONFIG_DIR/timelapse.cfg" > /dev/null 2>&1
    fi
}

# Klipper Print Time Estimator feature
setup4_yes() {
    edit_config enable "analysis" moonraker > /dev/null 2>&1
}

setup4_no() {
    edit_config disable "analysis" moonraker > /dev/null 2>&1
}

# BigTreeTech MMB Cubic
setup5_yes() {
    MMB_CUBIC=$(find /dev/serial/by-id/ -name 'usb-Klipper_rp2040*' 2>/dev/null | head -n 1)
    if [[ -n "$MMB_CUBIC" ]]; then
        edit_config enable "mcu MMB_Cubic" config > /dev/null 2>&1
        sed -i "s|^serial: /dev/serial/by-id/usb-Klipper_rp2040_.*|serial: $MMB_CUBIC|" "$CONFIG_DIR/config.cfg" > /dev/null 2>&1
    else
        curl -X POST "http://localhost:7125/printer/gcode/script" \
             -d "{\"script\": \"_SETUP_NOT_FOUND\"}" \
             -H "Content-Type: application/json" &
    fi
}

setup5_no() {
    edit_config disable "mcu MMB_Cubic" config > /dev/null 2>&1
    sed -i "s|^\#\serial: /dev/serial/by-id/usb-Klipper_rp2040_.*|#serial: /dev/serial/by-id/usb-Klipper_rp2040_xxxxx|" "$CONFIG_DIR/config.cfg" > /dev/null 2>&1
    edit_config disable "include Configurations/temp-sensor-mmb-cubic.cfg" config > /dev/null 2>&1
    edit_config enable "include Configurations/led-stock.cfg" config > /dev/null 2>&1
    edit_config disable "include Configurations/led-mmb-cubic.cfg" config > /dev/null 2>&1
}

# Chamber Temperature Sensor
setup6_yes() {
    edit_config enable "include Configurations/temp-sensor-mmb-cubic.cfg" config > /dev/null 2>&1
}

setup6_no() {
    edit_config disable "include Configurations/temp-sensor-mmb-cubic.cfg" config > /dev/null 2>&1
}

# Neopixels LEDs
setup7_yes() {
    edit_config disable "include Configurations/led-stock.cfg" config > /dev/null 2>&1
    edit_config enable "include Configurations/led-mmb-cubic.cfg" config > /dev/null 2>&1
}

setup7_no() {
    edit_config enable "include Configurations/led-stock.cfg" config > /dev/null 2>&1
    edit_config disable "include Configurations/led-mmb-cubic.cfg" config > /dev/null 2>&1
}

# BigTreeTech Smart Filament Sensor V2.0
setup8_yes() {
    edit_config disable "include Configurations/filament-sensor-stock.cfg" config > /dev/null 2>&1
    edit_config enable "include Configurations/filament-sensor-sfs.cfg" config > /dev/null 2>&1
}

setup8_no() {
    edit_config enable "include Configurations/filament-sensor-stock.cfg" config > /dev/null 2>&1
    edit_config disable "include Configurations/filament-sensor-sfs.cfg" config > /dev/null 2>&1
}

restart_services() {
    curl -X POST "http://localhost:7125/machine/services/restart" \
         -d '{"service": "klipper"}' \
         -H "Content-Type: application/json"
    curl -X POST "http://localhost:7125/machine/services/restart" \
             -d '{"service": "moonraker"}' \
             -H "Content-Type: application/json"
}

case "$1" in
    -setup1-yes)
        setup1_yes
        ;;
    -setup1-no)
        setup1_no
        ;;
    -setup2-yes)
        setup2_yes
        ;;
    -setup2-no)
        setup2_no
        ;;
    -setup3-yes)
        setup3_yes
        ;;
    -setup3-no)
        setup3_no
        ;;
    -setup4-yes)
        setup4_yes
        ;;
    -setup4-no)
        setup4_no
        ;;
    -setup5-yes)
        setup5_yes
        ;;
    -setup5-no)
        setup5_no
        ;;
    -setup6-yes)
        setup6_yes
        ;;
    -setup6-no)
        setup6_no
        ;;
    -setup7-yes)
        setup7_yes
        ;;
    -setup7-no)
        setup7_no
        ;;
    -setup8-yes)
        setup8_yes
        ;;
    -setup8-no)
        setup8_no
        ;;
    -restart-services)
        restart_services
        ;;
    *)
        exit 1
        ;;
esac
