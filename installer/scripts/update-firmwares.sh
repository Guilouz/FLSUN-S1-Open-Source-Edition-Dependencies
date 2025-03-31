#!/bin/bash
# FLSUN S1 Open Source Edition

set -e

function update_motherboard_firmware_message(){
    top_line
    title 'Update Motherboard MCU firmware' "${cyan}"
    inner_line
    hr
    echo -e " │ Build and Update Motherboard MCU firmware.                     │"
    hr
    echo -e " │ Note: This is only possible if you use Katapult Bootloader.    │"
    hr
    bottom_line
}

function update_cubic_firmware_message(){
    top_line
    title 'Update MMB Cubic MCU firmware' "${cyan}"
    inner_line
    hr
    echo -e " │ Build and Update BigTreeTech MMB Cubic MCU firmware.           │"
    hr
    bottom_line
}

function update_motherboard_firmware(){
    update_motherboard_firmware_message
    local yn
    while true; do
        read -p "${white}  Do you want to update Motherboard MCU firmware? (${cyan}y${white}/${cyan}n${white}): ${cyan}" yn
        case "${yn}" in
            Y|y)
                echo -e "${white}"
                info_msg "Stopping Klipper service..."
                stop_klipper
                echo
                info_msg "Updating repository..."
                echo
                pushd /home/pi/klipper > /dev/null 2>&1
                git fetch > /dev/null 2>&1
                git reset --hard origin/master > /dev/null 2>&1
                info_msg "Compiling Motherboard firmware..."
                echo
                cp /home/pi/flsun-os/installer/files/config.motherboard .config > /dev/null 2>&1
                set +e
                make clean > /dev/null 2>&1
                make olddefconfig > /dev/null 2>&1
                make
                set -e
                if [[ ! -f out/klipper.bin ]]; then
                    error_msg "Motherboard firmware file was not built!"
                    popd > /dev/null 2>&1
                    return
                fi
                ok_msg "Motherboard firmware has been built successfully!"
                info_msg "Flashing Motherboard firmware..."
                echo
                set +e
                python3 /home/pi/katapult/scripts/flashtool.py -d /dev/serial/by-id/usb-1a86_USB_Serial-if00-port0 -r
                echo
                python3 /home/pi/katapult/scripts/flashtool.py -f out/klipper.bin -d /dev/serial/by-id/usb-1a86_USB_Serial-if00-port0
                set -e
                popd > /dev/null 2>&1
                echo
                info_msg "Starting Klipper service..."
                start_klipper
                ok_msg "Motherboard firmware has been flashed successfully!"
                return;;
            N|n)
                error_msg "Update canceled!"
                return;;
            *)
                error_msg "Please select a correct choice!";;
        esac
    done
}

function update_cubic_firmware(){
    update_cubic_firmware_message
    local yn
    while true; do
        read -p "${white}  Do you want to update MMB Cubic MCU firmware? (${cyan}y${white}/${cyan}n${white}): ${cyan}" yn
        case "${yn}" in
            Y|y)
                echo -e "${white}"
                MMB_CUBIC=$(find /dev/serial/by-id/ -name 'usb-Klipper_rp2040*' 2>/dev/null | head -n 1)
                if [[ -z "$MMB_CUBIC" ]]; then
                    error_msg "No MMB Cubic device found! Please check the connection."
                    return
                fi
                info_msg "Stopping Klipper service..."
                stop_klipper
                echo
                info_msg "Updating repository..."
                echo
                pushd /home/pi/klipper > /dev/null 2>&1
                git fetch > /dev/null 2>&1
                git reset --hard origin/master > /dev/null 2>&1
                info_msg "Compiling MMB Cubic firmware..."
                echo
	            cp /home/pi/flsun-os/installer/files/config.cubic .config > /dev/null 2>&1
	            set +e
                make clean > /dev/null 2>&1
                make olddefconfig > /dev/null 2>&1
                make
                set -e
                if [[ ! -f out/klipper.uf2 ]]; then
                    error_msg "MMB Cubic firmware file was not built!"
                    popd > /dev/null 2>&1
                    return
                fi
                ok_msg "MMB Cubic firmware has been built successfully!"
                info_msg "Flashing MMB Cubic firmware..."
                echo
                set +e
                make flash FLASH_DEVICE="$MMB_CUBIC"
                sleep 2
                set -e
                popd > /dev/null 2>&1
                echo
                info_msg "Starting Klipper service..."
                start_klipper
                ok_msg "MMB Cubic firmware has been flashed successfully!\n    Turn the printer off and on."
                return;;
            N|n)
                error_msg "Update canceled!"
                return;;
            *)
                error_msg "Please select a correct choice!";;
        esac
    done
}
