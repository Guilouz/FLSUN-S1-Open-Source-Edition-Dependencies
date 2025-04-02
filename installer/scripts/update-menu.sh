#!/bin/bash
# FLSUN S1 Open Source Edition

set -e

function update_menu_ui() {
    top_line
    title 'UPDATE MENU' "${cyan}"
    inner_line
    hr
    menu_option ' 1' 'Update Klipper configuration files'
    menu_option ' 2' 'Printer Setup Wizard'
    hr
    menu_option ' 3' 'Update Motherboard MCU firmware'
    menu_option ' 4' 'Update MMB Cubic MCU firmware'
    hr
    menu_option ' 5' 'Update Debian packages'
    hr
    inner_line
    hr
    bottom_menu_option 'b' 'Back to Main Menu' "${cyan}"
    bottom_menu_option 'q' 'Quit' "${darkred}"
    hr
    bottom_line
}

function update_menu() {
    clear
    update_menu_ui
    local update_menu_opt
    while true; do
        read -p "${white}  Type your choice and validate with Enter: ${cyan}" update_menu_opt
        case "${update_menu_opt}" in
            1)
                run "update_configuration_files" "update_menu_ui";;
            2)
                run "configure_my_printer" "update_menu_ui";;
            3)
                echo "${white}"
                echo "  Checking for the existence of the Katapult bootloader..."
                if python3 /home/pi/katapult/scripts/flashtool.py -d /dev/serial/by-id/usb-1a86_USB_Serial-if00-port0 -s 2>&1 | grep -q "FlashError: Error sending command \[CONNECT\] to Device"; then
                    error_msg "Katapult Bootloader is not installed! Please check the Wiki to install it."
                else
                    run "update_motherboard_firmware" "update_menu_ui"
                fi;;
            4)
                MMB_CUBIC=$(find /dev/serial/by-id/ -name 'usb-Klipper_rp2040*' 2>/dev/null | head -n 1)
                if [[ -n "$MMB_CUBIC" ]]; then
                    run "update_cubic_firmware" "update_menu_ui"
                else
                    error_msg "No MMB Cubic device found! Please check the connection."
                fi;;
            5)
                run "update_debian_packages" "update_menu_ui";;
            B|b)
                echo -e "${white}"
                clear; main_menu; break;;
            Q|q)
                echo -e "${white}"
                clear; run-parts /etc/update-motd.d; echo; exit 0;;
            *)
                error_msg "Please select a correct choice!";;
        esac
    done
    update_menu
}
