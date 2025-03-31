#!/bin/bash
# FLSUN S1 Open Source Edition

set -e

function delete_cache_logs_message(){
    top_line
    title 'Delete cache and logs files' "${cyan}"
    inner_line
    hr
    echo -e " │ This allows to delete temporary files and log files.           │"
    hr
    bottom_line
}

function delete_cache_logs(){
    delete_cache_logs_message
    local yn
    while true; do
        read -p "${white}  Are you sure you want to delete ${cyan}cache and logs files${white}? (${cyan}y${white}/${cyan}n${white}): ${cyan}" yn
        case "${yn}" in
            Y|y)
                echo -e "${white}"
                info_msg "Deleting files..."
                if [ -d "/home/pi/.local/share/spoolman" ]; then
                    sudo rm -f /home/pi/.local/share/spoolman/spoolman.log* > /dev/null 2>&1
                fi
                sudo rm -f /home/pi/guppyflo/guppyflo.log > /dev/null 2>&1
                sudo rm -rf /home/pi/.cache/pip > /dev/null 2>&1
                sudo rm -rf /home/pi/.cache/fontconfig > /dev/null 2>&1
                sudo rm -f /home/pi/printer_data/logs/* > /dev/null 2>&1
                sudo rm -rf /tmp/* /tmp/.* > /dev/null 2>&1
                sudo rm -rf /var/cache/* > /dev/null 2>&1
                ok_msg "Cache and log files have been deleted!"
                return;;
            N|n)
                error_msg "Deletion canceled!"
                return;;
            *)
                error_msg "Please select a correct choice!";;
        esac
    done
}
