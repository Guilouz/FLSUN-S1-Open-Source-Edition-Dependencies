#!/bin/bash
# FLSUN S1 Open Source Edition

BASE_DIR="/home/pi/klipper/config/FLSUN S1/"
LOCAL_DIR="/home/pi/printer_data/config/"
FILES=(
    "Configurations/camera-control.cfg"
    "Configurations/fan-silent-kit.cfg"
    "Configurations/fan-stock.cfg"
    "Configurations/filament-sensor-sfs.cfg"
    "Configurations/filament-sensor-stock.cfg"
    "Configurations/flsun-os.cfg"
    "Configurations/led-mmb-cubic.cfg"
    "Configurations/led-stock.cfg"
    "Configurations/macros.cfg"
    "Configurations/temp-sensor-mmb-cubic.cfg"
    "KlipperScreen.conf"
    "config.cfg"
    "moonraker.conf"
    "printer.cfg"
    "webcam.txt"
)

function update_configuration_files_message(){
    top_line
    title 'Update Klipper configuration files' "${cyan}"
    inner_line
    hr
    echo -e " │ Update to latest Klipper configuration files.                  │"
    hr
    bottom_line
}

get_version() {
    grep -oP '(?<=# Version: )\d+\.\d+' "$1" | head -n 1 2>/dev/null
}

update_available=false
recalibrate=false
reconfigure=false
restart_klipperscreen=false
restart_moonraker=false
restart_webcamd=false

check_update_available() {
    update_available=false
    for file in "${FILES[@]}"; do
        base_file="${BASE_DIR}${file}"
        local_file="${LOCAL_DIR}${file}"

        if [[ ! -f "$base_file" ]]; then
            continue
        fi

        if [[ ! -f "$local_file" ]]; then
            update_available=true
            return
        fi

        remote_version=$(get_version "$base_file")
        local_version=$(get_version "$local_file")

        if [[ -n "$remote_version" && ( -z "$local_version" || "$remote_version" > "$local_version" ) ]]; then
            update_available=true
            return
        fi
    done
}

backup_config() {
    CURRENT_DATE=$(date +"%Y%m%d_%H%M%S")
    BACKUP_FILE="config_backup_$CURRENT_DATE.zip"
    cd "$LOCAL_DIR" || exit
    find . -type f \( -name "*.cfg" -o -name "*.conf" -o -name "*.txt" \) ! -name "printer-*.cfg" | zip -@ "$BACKUP_FILE" > /dev/null 2>&1
    cd - > /dev/null
}

copy_files() {
    declare -g recalibrate=false
    declare -g reconfigure=false
    declare -g restart_klipperscreen=false
    declare -g restart_moonraker=false
    declare -g restart_webcamd=false

    for file in "${FILES[@]}"; do
        base_file="${BASE_DIR}${file}"
        local_file="${LOCAL_DIR}${file}"

        if [[ ! -f "$base_file" ]]; then
            continue
        fi

        mkdir -p "$(dirname "$local_file")"

        if [[ ! -f "$local_file" ]]; then
            info_msg "Updating $(basename "$file") file..."
            echo
            cp "$base_file" "$local_file" > /dev/null 2>&1
            [[ "$file" == "KlipperScreen.conf" ]] && restart_klipperscreen=true
            [[ "$file" == "moonraker.conf" ]] && restart_moonraker=true && reconfigure=true
            [[ "$file" == "webcam.txt" ]] && restart_webcamd=true
            [[ "$file" == "printer.cfg" ]] && recalibrate=true
            [[ "$file" == "config.cfg" ]] && reconfigure=true
            continue
        fi

        remote_version=$(get_version "$base_file")
        local_version=$(get_version "$local_file")

        if [[ -n "$remote_version" && ( -z "$local_version" || "$remote_version" > "$local_version" ) ]]; then
            info_msg "Updating $(basename "$file") file..."
            echo
            cp "$base_file" "$local_file" > /dev/null 2>&1
            [[ "$file" == "KlipperScreen.conf" ]] && restart_klipperscreen=true
            [[ "$file" == "moonraker.conf" ]] && restart_moonraker=true && reconfigure=true
            [[ "$file" == "webcam.txt" ]] && restart_webcamd=true
            [[ "$file" == "printer.cfg" ]] && recalibrate=true
            [[ "$file" == "config.cfg" ]] && reconfigure=true
        fi
    done
}

function update_configuration_files(){
    update_configuration_files_message
    check_update_available
    local yn
    while true; do
        read -p "${white}  Do you want to update Klipper configuration files? (${cyan}y${white}/${cyan}n${white}): ${cyan}" yn
        case "${yn}" in
            Y|y)
                echo -e "${white}"
                if $update_available; then
                    info_msg "Backing up files..."
                    backup_config
                    echo
                    copy_files
                    if $restart_moonraker; then
                        info_msg "Restarting Moonraker service..."
                        restart_moonraker
                        echo
                    fi
                    info_msg "Restarting Klipper service..."
                    restart_klipper
                    echo
                    if $restart_klipperscreen; then
                        info_msg "Restarting KlipperScreen service..."
                        restart_klipperscreen
                        echo
                    fi
                    if $restart_webcamd; then
                        info_msg "Restarting Webcam service..."
                        restart_webcamd
                        echo
                    fi
                    if $recalibrate && $reconfigure; then
                        ok_msg "Klipper configuration files have been updated!"
                        read -p "    Your printer need to be reconfigured. Press Enter to continue..."
                        run "configure_my_printer"
                    elif $recalibrate; then
                        ok_msg "Klipper configuration files have been updated!\n    Please recalibrate your printer."
                    elif $reconfigure; then
                        ok_msg "Klipper configuration files have been updated!"
                        read -p "    Your printer need to be reconfigured. Press Enter to continue..."
                        run "configure_my_printer"
                    else
                        ok_msg "Klipper configuration files have been updated!"
                    fi
                else
                    error_msg "No new Klipper configuration files are available!\n    Make sure Klipper is up to date in the Update Manager."
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
