#!/bin/bash
# FLSUN S1 Open Source Edition

GUPPYFLO_SOURCE_FOLDER="/home/pi/flsun-os/installer/files/guppyflo"
GUPPYFLO_FOLDER="/home/pi/guppyflo"
GUPPYFLO_SERVICE_FILE="/etc/systemd/system/guppyflo.service"
GUPPYFLO_LOG_FILE="$GUPPYFLO_FOLDER/guppyflo.log"

set -e

function guppyflo_message(){
    top_line
    title 'GuppyFLO' "${cyan}"
    inner_line
    hr
    echo -e " │ GuppyFLO is a lightweight self-hosted service that allows      │"
    echo -e " │ remote management via TCP Proxy using Moonraker and Tailscale. │"
    hr
    bottom_line
}

display_post_install_instruction() {
    while true; do
        TS_AUTH_URL=$(grep -o -m 1 "https://login.tailscale.com/.*" "$GUPPYFLO_LOG_FILE" 2>/dev/null || echo "")
        TS_AUTHED=$(grep -o -m 1 "ts already authenticated" "$GUPPYFLO_LOG_FILE" 2>/dev/null || echo "")
        if [ -n "$TS_AUTH_URL" ] || [ -n "$TS_AUTHED" ]; then
            break
        fi
        sleep 2
    done
    if [ -n "$TS_AUTHED" ]; then
        echo -e "${cyan}  Follow these steps:${white}"
        echo
        echo -e "  1 - Create a Tailscale account or sign-in:"
        echo -e "${yellow}      https://login.tailscale.com/start${white}"
        echo
        echo -e "  2 - Make sure Tailscale MagicDNS is enabled:"
        echo -e "${yellow}      https://login.tailscale.com/admin/dns${white}"
        echo
        echo -e "  3 - Download the Tailscale client, sign-in, and connect your client to your tailnet:"
        echo -e "${yellow}      https://tailscale.com/download${white}"
        echo
        echo -e "  4 - Remote access to Mainsail at:"
        echo -e "${yellow}      http://guppyflo${white}"
        echo
        echo -e "  5 - Remote access to Fluidd if installed at:"
        echo -e "${yellow}      http://guppyflo:81${white}"
        echo
    else
        echo -e "${cyan}  Follow these steps:${white}"
        echo
        echo -e "  1 - Create a Tailscale account or sign-in:"
        echo -e "${yellow}      https://login.tailscale.com/start${white}"
        echo
        echo -e "  2 - Make sure Tailscale MagicDNS is enabled:"
        echo -e "${yellow}      https://login.tailscale.com/admin/dns${white}"
        echo
        echo -e "  3 - Open this URL to add this printer to your tailnet:"
        echo -e "${yellow}      $TS_AUTH_URL${white}"
        echo
        echo -e "  4 - Download the Tailscale client, sign-in, and connect your client to your tailnet:"
        echo -e "${yellow}      https://tailscale.com/download${white}"
        echo
        echo -e "  5 - Remote access to Mainsail at:"
        echo -e "${yellow}      http://guppyflo${white}"
        echo
        echo -e "  6 - Remote access to Fluidd if installed at:"
        echo -e "${yellow}      http://guppyflo:81${white}"
        echo
    fi
}

function install_guppyflo(){
    guppyflo_message
    local yn
    while true; do
        install_msg "GuppyFLO" yn
        case "${yn}" in
            Y|y)
                echo -e "${white}"
                if [ -f "$GUPPYFLO_SERVICE_FILE" ]; then
                    info_msg "Stopping GuppyFLO service..."
                    echo
                    sudo systemctl stop guppyflo > /dev/null 2>&1
                    sudo systemctl disable guppyflo.service > /dev/null 2>&1
                    echo
                fi
                if [ -f "$GUPPYFLO_SERVICE_FILE" ]; then
                    sudo rm -f "$GUPPYFLO_SERVICE_FILE" > /dev/null 2>&1
                fi
                if [ -d "$GUPPYFLO_FOLDER" ]; then
                    sudo rm -rf "$GUPPYFLO_FOLDER" > /dev/null 2>&1
                fi
                info_msg "Copying files..."
                echo
                sudo cp -rp "$GUPPYFLO_SOURCE_FOLDER" "$GUPPYFLO_FOLDER" > /dev/null 2>&1
                sudo cp "$GUPPYFLO_FOLDER/services/guppyflo.service" "$GUPPYFLO_SERVICE_FILE" > /dev/null 2>&1
                info_msg "Configuring GuppyFLO service..."
                echo
                sudo systemctl enable guppyflo.service > /dev/null 2>&1
                info_msg "Starting GuppyFLO service..."
                if [ -f "$GUPPYFLO_LOG_FILE" ]; then
                    sudo rm -f "$GUPPYFLO_LOG_FILE" > /dev/null 2>&1
                fi
                sudo systemctl restart guppyflo > /dev/null 2>&1
                ok_msg "GuppyFLO configuration done! Waiting for Tailscale info to be available..."
                display_post_install_instruction
                return;;
            N|n)
                error_msg "Installation canceled!"
                return;;
            *)
                error_msg "Please select a correct choice!";;
        esac
    done
}

function remove_guppyflo(){
    guppyflo_message
    local yn
    while true; do
        remove_msg "GuppyFLO" yn
        case "${yn}" in
            Y|y)
                echo -e "${white}"
                if [ -f "$GUPPYFLO_SERVICE_FILE" ]; then
                    info_msg "Stopping GuppyFLO service..."
                    echo
                    sudo systemctl stop guppyflo > /dev/null 2>&1
                    sudo systemctl disable guppyflo.service > /dev/null 2>&1
                fi
                info_msg "Deleting files..."
                if [ -f "$GUPPYFLO_SERVICE_FILE" ]; then
                    sudo rm -f "$GUPPYFLO_SERVICE_FILE" > /dev/null 2>&1
                    sudo rm -rf "$GUPPYFLO_FOLDER" > /dev/null 2>&1
                fi
                if [ -d "/home/pi/.config/tsnet-guppyflo" ]; then
                    sudo rm -rf "/home/pi/.config/tsnet-guppyflo" > /dev/null 2>&1
                fi
                if [ -d "/home/pi/.local/share/tailscale/" ]; then
                    sudo rm -rf "/home/pi/.local/share/tailscale/" > /dev/null 2>&1
                fi
                ok_msg "GuppyFLO has been removed successfully!"
                return;;
            N|n)
                error_msg "Deletion canceled!"
                return;;
            *)
                error_msg "Please select a correct choice!";;
        esac
    done
}
