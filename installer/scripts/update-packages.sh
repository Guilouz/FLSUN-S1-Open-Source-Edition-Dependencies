#!/bin/bash
# FLSUN S1 Open Source Edition

set -e

function update_debian_packages_message(){
    top_line
    title 'Update Debian packages' "${cyan}"
    inner_line
    hr
    echo -e " │ This allows to update installed packages from Debian           │"
    echo -e " │ repository.                                                    │"
    hr
    bottom_line
}

function update_debian_packages(){
    update_debian_packages_message
    local yn
    while true; do
        read -p "${white}  Are you sure you want to update ${cyan}Debian packages${white}? (${cyan}y${white}/${cyan}n${white}): ${cyan}" yn
        case "${yn}" in
            Y|y)
                echo -e "${white}"
                info_msg "Updating packages list..."
                echo
                sudo apt update
                if [ -z "$(apt list --upgradable 2>/dev/null | grep -v 'Listing...')" ]; then
                    ok_msg "No package need to be updated!"
                else
                    echo
                    info_msg "Updating outdated packages..."
                    echo
                    sudo apt upgrade -y
                    info_msg "Cleaning cache..."
                    echo
                    sudo apt clean
                    sudo apt autoremove
                    sudo apt autoclean
                    ok_msg "Outdated packages have been updated!"
                fi
                return;;
            N|n)
                error_msg "Update canceled!"
                return;;
            *)
                error_msg "Please select a correct choice!";;
        esac
    done
}
