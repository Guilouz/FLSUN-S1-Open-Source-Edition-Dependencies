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
    "Configurations/led-mmb-cubic.cfg"
    "Configurations/led-stock.cfg"
    "Configurations/macros.cfg"
    "Configurations/setup-printer.cfg"
    "Configurations/temp-sensor-mmb-cubic.cfg"
    "KlipperScreen.conf"
    "config.cfg"
    "moonraker.conf"
    "printer.cfg"
    "webcam.txt"
)

get_version() {
    grep -oP '(?<=# Version: )\d+\.\d+' "$1" | head -n 1 2>/dev/null
}

check_updates() {
    local silent=$1
    update_available=false
    recalibrate=false
    reconfigure=false

    for file in "${FILES[@]}"; do
        base_file="${BASE_DIR}${file}"
        local_file="${LOCAL_DIR}${file}"

        if [[ ! -f "$base_file" ]]; then
            continue
        fi

        if [[ ! -f "$local_file" ]]; then
            update_available=true
            updated_files+=("$(basename "$file")")
            continue
        fi

        remote_version=$(get_version "$base_file")
        local_version=$(get_version "$local_file")

        if [[ -n "$remote_version" && ( -z "$local_version" || "$remote_version" > "$local_version" ) ]]; then
            update_available=true
            updated_files+=("$(basename "$file")")
            [[ "$file" == "printer.cfg" ]] && recalibrate=true
            [[ "$file" == "config.cfg" ]] && reconfigure=true
            [[ "$file" == "moonraker.conf" ]] && reconfigure=true
        fi
    done
    
    UPDATE_FILES=$(IFS=','; eval 'echo "${updated_files[*]}"' | sed 's/,/, /g')

    if $update_available; then
        if $recalibrate && $reconfigure; then
            curl -X POST "http://localhost:7125/printer/gcode/script" \
                 -d "{\"script\": \"_UPDATE FILES=\\\"${UPDATE_FILES}\\\" RECONFIGURE=true RECALIBRATE=true\"}" \
                 -H "Content-Type: application/json" &
        elif $recalibrate; then
            curl -X POST "http://localhost:7125/printer/gcode/script" \
                 -d "{\"script\": \"_UPDATE FILES=\\\"${UPDATE_FILES}\\\" RECALIBRATE=true\"}" \
                 -H "Content-Type: application/json" &
        elif $reconfigure; then
            curl -X POST "http://localhost:7125/printer/gcode/script" \
                 -d "{\"script\": \"_UPDATE FILES=\\\"${UPDATE_FILES}\\\" RECONFIGURE=true\"}" \
                 -H "Content-Type: application/json" &
        else
            curl -X POST "http://localhost:7125/printer/gcode/script" \
                 -d "{\"script\": \"_UPDATE FILES=\\\"${UPDATE_FILES}\\\"\"}" \
                 -H "Content-Type: application/json" &
        fi
    else
        if [[ $silent != "silent" ]]; then
            curl -X POST "http://localhost:7125/printer/gcode/script" \
                 -d "{\"script\": \"_NO_UPDATE\"}" \
                 -H "Content-Type: application/json" &
        fi
    fi
}

backup_config() {
    CURRENT_DATE=$(date +"%Y%m%d_%H%M%S")
    BACKUP_FILE="config_backup_$CURRENT_DATE.zip"
    cd "$LOCAL_DIR" || exit
    find . -type f \( -name "*.cfg" -o -name "*.conf" -o -name "*.txt" \) ! -name "printer-*.cfg" | zip -@ "$BACKUP_FILE"
    cd - > /dev/null
}

copy_updates() {
    restart_klipperscreen=false
    restart_moonraker=false
    restart_webcamd=false

    backup_config

    for file in "${FILES[@]}"; do
        base_file="${BASE_DIR}${file}"
        local_file="${LOCAL_DIR}${file}"

        if [[ ! -f "$base_file" ]]; then
            continue
        fi

        mkdir -p "$(dirname "$local_file")"

        if [[ ! -f "$local_file" ]]; then
            cp "$base_file" "$local_file"
            [[ "$file" == "KlipperScreen.conf" ]] && restart_klipperscreen=true
            [[ "$file" == "moonraker.conf" ]] && restart_moonraker=true
            [[ "$file" == "webcam.txt" ]] && restart_webcamd=true
            continue
        fi

        remote_version=$(get_version "$base_file")
        local_version=$(get_version "$local_file")

        if [[ -n "$remote_version" && ( -z "$local_version" || "$remote_version" > "$local_version" ) ]]; then
            cp "$base_file" "$local_file"
            [[ "$file" == "KlipperScreen.conf" ]] && restart_klipperscreen=true
            [[ "$file" == "moonraker.conf" ]] && restart_moonraker=true
            [[ "$file" == "webcam.txt" ]] && restart_webcamd=true
        fi
    done

    curl -X POST "http://localhost:7125/machine/services/restart" \
         -d '{"service": "klipper"}' \
         -H "Content-Type: application/json"
    if $restart_klipperscreen; then
        curl -X POST "http://localhost:7125/machine/services/restart" \
             -d '{"service": "KlipperScreen"}' \
             -H "Content-Type: application/json"
    fi
    if $restart_webcamd; then
        curl -X POST "http://localhost:7125/machine/services/restart" \
             -d '{"service": "webcamd"}' \
             -H "Content-Type: application/json"
    fi
    if $restart_moonraker; then
        curl -X POST "http://localhost:7125/machine/services/restart" \
             -d '{"service": "moonraker"}' \
             -H "Content-Type: application/json"
    fi
}

case "$1" in
    -check-updates)
        check_updates
        ;;
    -check-updates-silent)
        check_updates silent
        ;;
    -copy-updates)
        copy_updates
        ;;
    -backup-config)
        backup_config
        ;;
    *)
        echo "Usage: $0 {-check-updates|-copy-update|-backup-config}"
        exit 1
        ;;
esac
