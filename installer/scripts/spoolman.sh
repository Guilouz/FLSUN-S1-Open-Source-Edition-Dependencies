#!/bin/bash
# FLSUN S1 Open Source Edition

SPOOLMAN_URL="https://github.com/Donkie/Spoolman/releases/latest/download/spoolman.zip"
SPOOLMAN_FOLDER="/home/pi/Spoolman"
SPOOLMAN_OLD_FOLDER="/home/pi/Spoolman_old"
SPOOLMAN_SERVICE_FILE="/etc/systemd/system/Spoolman.service"
MOONRAKER_CFG="/home/pi/printer_data/config/moonraker.conf"
IP_ADDRESS=$(hostname -I | cut -d " " -f1)

set -e

function spoolman_message(){
    top_line
    title 'Spoolman' "${cyan}"
    inner_line
    hr
    echo -e " │ Spoolman is a self-hosted web service designed to help you     │"
    echo -e " │ efficiently manage your 3D printer filament spools and monitor │"
    echo -e " │ their usage.                                                   │"
    hr
    bottom_line
}

function install_spoolman(){
    spoolman_message
    local yn
    while true; do
        read -p "${white}  Are you sure you want to install or update ${cyan}Spoolman${white}? (${cyan}y${white}/${cyan}n${white}): ${cyan}" yn
        case "${yn}" in
            Y|y)
                echo -e "${white}"
                if [ -f "$SPOOLMAN_SERVICE_FILE" ]; then
                    info_msg "Stopping Spoolman service..."
                    echo
                    sudo systemctl disable --now Spoolman > /dev/null 2>&1
                    echo
                fi
                if [ -d "$SPOOLMAN_FOLDER" ]; then
                    sudo mv "$SPOOLMAN_FOLDER" "$SPOOLMAN_OLD_FOLDER" > /dev/null 2>&1
                fi
                mkdir -p "$SPOOLMAN_FOLDER"
                info_msg "Downloading file..."
                echo
                if [ -f "/home/pi/spoolman.zip" ]; then
                    sudo rm -f "/home/pi/spoolman.zip" > /dev/null 2>&1
                fi
                echo
                curl -L "$SPOOLMAN_URL" -o "/home/pi/spoolman.zip" || { echo; echo "${white}${darkred}  ✗ Error downloading spoolman.zip${white}"; echo; exit 1; }
                info_msg "Extracting files..."
                echo
                unzip /home/pi/spoolman.zip -d "$SPOOLMAN_FOLDER" > /dev/null 2>&1 || { echo; echo "${white}${darkred}  ✗ Error extracting spoolman.zip${white}"; echo; exit 1; }
                sudo rm -f /home/pi/spoolman.zip > /dev/null 2>&1
                info_msg "Starting Spoolman installation..."
                echo
                if [ -d "$SPOOLMAN_OLD_FOLDER" ]; then
                    sudo cp "$SPOOLMAN_OLD_FOLDER"/.env "$SPOOLMAN_FOLDER"/.env > /dev/null 2>&1
                    sudo rm -rf "$SPOOLMAN_OLD_FOLDER" > /dev/null 2>&1
                fi
                cd "$SPOOLMAN_FOLDER"
                echo "y" | bash ./scripts/install.sh
                echo
                info_msg "Configuring files..."
                echo
                grep -qxF "Spoolman" /home/pi/printer_data/moonraker.asvc || sed -i '$ a Spoolman' /home/pi/printer_data/moonraker.asvc > /dev/null 2>&1
                sed -i "/^\#\[spoolman\]/ s/^#//; /^\#server: http:\/\/xxx\.xxx\.xxx\.xxx:7912/ s/^#//; s/xxx\.xxx\.xxx\.xxx/$IP_ADDRESS/" "$MOONRAKER_CFG" > /dev/null 2>&1
                sudo rm -rf /home/pi/.cache/pip > /dev/null 2>&1
                info_msg "Restarting Moonraker service..."
                restart_moonraker
                ok_msg "Spoolman has been installed successfully!"
                echo -e "    You can now connect to Spoolman Web Interface with ${yellow}http://$IP_ADDRESS:7912 ${white}"
                echo
                return;;
            N|n)
                error_msg "Installation canceled!"
                return;;
            *)
                error_msg "Please select a correct choice!";;
        esac
    done
}

function remove_spoolman(){
    spoolman_message
    local yn
    while true; do
        remove_msg "Spoolman" yn
        case "${yn}" in
            Y|y)
                echo -e "${white}"
                if [ -f "$SPOOLMAN_SERVICE_FILE" ]; then
                    info_msg "Stopping Spoolman service..."
                    echo
                    sudo systemctl disable --now Spoolman > /dev/null 2>&1
                fi
                if [ -f "$SPOOLMAN_SERVICE_FILE" ]; then
                    sudo rm -f "$SPOOLMAN_SERVICE_FILE" > /dev/null 2>&1
                fi
                if [ -d "$SPOOLMAN_FOLDER" ]; then
                    sudo rm -rf "$SPOOLMAN_FOLDER" > /dev/null 2>&1
                fi
                while true; do
                    read -p "${white}  Do you want to delete Spoolman database? (${cyan}y${white}/${cyan}n${white}): ${cyan}" delete_database
                    case "${delete_database}" in
                        Y|y)
                            echo -e "${white}"
                            if [ -d "/home/pi/.local/share/spoolman" ]; then
                                info_msg "Deleting files..."
                                echo
                                sudo rm -rf "/home/pi/.local/share/spoolman" > /dev/null 2>&1
                            fi
                            break;;
                        N|n)
                            echo -e "${white}"
                            break;;
                        *)
                            error_msg "Please select a correct choice!";;
                    esac
                done
                info_msg "Configuring files..."
                echo
                sed -i "/^\[spoolman\]/ s/^/#/; /^\s*server: http:\/\/$IP_ADDRESS:7912/ s/^/#/; s/$IP_ADDRESS/xxx.xxx.xxx.xxx/" "$MOONRAKER_CFG" > /dev/null 2>&1
                info_msg "Restarting Moonraker service..."
                restart_moonraker
                ok_msg "Spoolman has been removed successfully!"
                return;;
            N|n)
                error_msg "Deletion canceled!"
                return;;
            *)
                error_msg "Please select a correct choice!";;
        esac
    done
}
