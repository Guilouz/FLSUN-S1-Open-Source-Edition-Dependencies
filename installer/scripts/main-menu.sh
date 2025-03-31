#!/bin/bash
# FLSUN S1 Open Source Edition

set -e

function main_menu_ui() {
    top_line
    hr
    echo -e "${white} │  ███████████  ██          ████████     ██        ███   ${cyan}██████  ${white}│"
    echo -e "${white} │  ██           ██         ██            ██        █████   ${cyan}████  ${white}│"
    echo -e "${white} │  ███████      ██         ████████████  ██            ███   ${cyan}██  ${white}│"
    echo -e "${white} │  ██           ██                   ██  ██        ██    ███     │"
    echo -e "${white} │  ██           ████████  ████████████    ██████████       ███   │"
    hr
    title "EASY INSTALLER FOR FLSUN S1" "${cyan}"
    inner_line
    echo -e "${white} │              Copyright © Cyril Guislain (Guilouz)              │"
    inner_line
    hr
    main_menu_option '1' 'Install' 'Menu'
    main_menu_option '2' 'Remove' 'Menu'
    main_menu_option '3' 'Update' 'Menu'
    main_menu_option '4' 'Extras' 'Menu'
    hr
    inner_line
    hr
    bottom_menu_option 'q' 'Quit' "${darkred}"
    hr
    echo -e " │                                                           ${cyan}v2.0${white} │"
    bottom_line
}

function main_menu() {
    clear
    main_menu_ui
    local main_menu_opt
    while true; do
        read -p "${white}  Type your choice and validate with Enter: ${cyan}" main_menu_opt
        case "${main_menu_opt}" in
            1) 
                clear
                install_menu
                break;;
            2) 
                clear
                remove_menu
                break;;
            3) 
                clear
                update_menu
                break;;
            4) 
                clear
                extras_menu
                break;;
            Q|q)
                echo -e "${white}"
                clear; run-parts /etc/update-motd.d; echo; exit 0;;
            *)
                error_msg "Please select a correct choice!";;
        esac
    done
    main_menu
}
