#!/bin/bash
# FLSUN S1 Open Source Edition

set -e

function extras_menu_ui() {
    top_line
    title 'EXTRAS MENU' "${cyan}"
    inner_line
    hr
    menu_option ' 1' 'Backup Klipper configuration files'
    menu_option ' 2' 'Restore Klipper configuration files'
    menu_option ' 3' 'Backup Moonraker database'
    menu_option ' 4' 'Restore Moonraker database'
    hr
    menu_option ' 5' 'Restore Web-UI default settings'
    hr
    menu_option ' 6' 'Delete cache and logs files'
    hr
    menu_option ' 7' 'Restore SSH access for Stock OS'
    hr
    inner_line
    hr
    bottom_menu_option 'b' 'Back to Main Menu' "${cyan}"
    bottom_menu_option 'q' 'Quit' "${darkred}"
    hr
    bottom_line
}

function extras_menu() {
    clear
    extras_menu_ui
    local extras_menu_opt
    while true; do
        read -p "${white}  Type your choice and validate with Enter: ${cyan}" extras_menu_opt
        case "${extras_menu_opt}" in
            1)
                run "backup_klipper" "extras_menu_ui";;
            2)
                if [ ! -f "/home/pi/printer_data/config/backup_klipper.zip" ]; then
                    error_msg "Please backup Klipper configuration files before restore!"
                else
                    run "restore_klipper" "extras_menu_ui"
                fi;;
            3)
                run "backup_moonraker" "extras_menu_ui";;
            4)
                if [ ! -f "/home/pi/printer_data/config/backup_moonraker.zip" ]; then
                    error_msg "Please backup Moonraker database before restore!"
                else
                    run "restore_moonraker" "extras_menu_ui"
                fi;;
            5)
                run "restore_web_ui_settings" "extras_menu_ui";;
            6)
                run "delete_cache_logs" "extras_menu_ui";;
            7)
                run "restore_ssh_access" "extras_menu_ui";;
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
    extras_menu
}
