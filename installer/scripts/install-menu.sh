#!/bin/bash
# FLSUN S1 Open Source Edition

set -e

function install_menu_ui() {
    top_line
    title 'INSTALL MENU' "${cyan}"
    inner_line
    hr
    menu_option ' 1' 'Install or Update' 'Spoolman'
    menu_option ' 2' 'Install' 'GuppyFLO'
    hr
    inner_line
    hr
    bottom_menu_option 'b' 'Back to Main Menu' "${cyan}"
    bottom_menu_option 'q' 'Quit' "${darkred}"
    hr
    bottom_line
}

function install_menu() {
    clear
    install_menu_ui
    local install_menu_opt
    while true; do
        read -p "${white}  Type your choice and validate with Enter: ${cyan}" install_menu_opt
        case "${install_menu_opt}" in
            1)
                run "install_spoolman" "install_menu_ui";;
            2)
                if [ -f "/etc/systemd/system/guppyflo.service" ]; then  
                    error_msg "GuppyFLO is already installed!"
                else
                    run "install_guppyflo" "install_menu_ui"
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
    install_menu
}
