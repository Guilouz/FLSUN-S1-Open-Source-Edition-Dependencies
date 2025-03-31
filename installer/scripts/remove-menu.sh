#!/bin/bash
# FLSUN S1 Open Source Edition

set -e

function remove_menu_ui() {
    top_line
    title 'REMOVE MENU' "${cyan}"
    inner_line
    hr
    menu_option ' 1' 'Remove' 'Spoolman'
    menu_option ' 2' 'Remove' 'GuppyFLO'
    hr
    inner_line
    hr
    bottom_menu_option 'b' 'Back to Main Menu' "${cyan}"
    bottom_menu_option 'q' 'Quit' "${darkred}"
    hr
    bottom_line
}

function remove_menu() {
    clear
    remove_menu_ui
    local remove_menu_opt
    while true; do
        read -p "${white}  Type your choice and validate with Enter: ${cyan}" remove_menu_opt
        case "${remove_menu_opt}" in
            1)
                if [ ! -d "$SPOOLMAN_FOLDER" ]; then
                    error_msg "Spoolman is not installed!"
                else
                    run "remove_spoolman" "remove_menu_ui"
                fi;;
            2)
                if [ ! -f "/etc/systemd/system/guppyflo.service" ]; then
                    error_msg "GuppyFLO is not installed!"
                else
                    run "remove_guppyflo" "remove_menu_ui"
                fi;;
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
    remove_menu
}
