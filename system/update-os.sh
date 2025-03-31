#!/bin/bash
# FLSUN S1 Open Source Edition

SCRIPT_VERSION="2.0"

OS_RELEASE_FILE="/usr/lib/os-release"

PRETTY_NAME=$(grep PRETTY_NAME "$OS_RELEASE_FILE" | cut -d '=' -f 2 | tr -d '"')
LOG_DIR="/home/pi/printer_data/logs"
LOG_FILE="$LOG_DIR/update-os.log"
mkdir -p "$LOG_DIR"

log_with_timestamp() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

log_output_with_timestamp() {
    while IFS= read -r line; do
        echo "[$(date +'%Y-%m-%d %H:%M:%S')] $line" | tee -a "$LOG_FILE"
    done
}

CURRENT_VERSION=$(echo "$PRETTY_NAME" | grep -oP '[0-9]+\.[0-9]+(\.[0-9]+)?')

if [[ ! "$CURRENT_VERSION" =~ ^[0-9]+\.[0-9]+(\.[0-9]+)?$ ]]; then
    log_with_timestamp "PRETTY_NAME incorrect format! Expected format: 'FLSUN OS X.X' or 'FLSUN OS X.X.X'"
    exit 1
fi

update_system() {
    log_with_timestamp "Updating OS..."
    curl -X POST "http://localhost:7125/printer/gcode/script" \
         -d "{\"script\": \"_OS_UPDATE_START CURRENT=${CURRENT_VERSION} NEW=${SCRIPT_VERSION}\"}" \
         -H "Content-Type: application/json"
    #sudo apt update 2>&1 | log_output_with_timestamp
    #sudo apt upgrade -y  2>&1 | log_output_with_timestamp
    return $?
}

if [ "$(echo -e "$CURRENT_VERSION\n$SCRIPT_VERSION" | sort -V | tail -n 1)" != "$CURRENT_VERSION" ]; then
    log_with_timestamp "OS update begins."
    log_with_timestamp "Current version: $CURRENT_VERSION"
    log_with_timestamp "New version: $SCRIPT_VERSION"

    update_system
    if [ $? -eq 0 ]; then
        sudo sed -i "s/\(PRETTY_NAME=\".*\)\($CURRENT_VERSION\)\(.*\"\)/\1$SCRIPT_VERSION\3/" "$OS_RELEASE_FILE"
        log_with_timestamp "OS successfully updated from $CURRENT_VERSION to $SCRIPT_VERSION."
        curl -X POST "http://localhost:7125/printer/gcode/script" \
             -d "{\"script\": \"_OS_UPDATE_SUCCESS NEW=${SCRIPT_VERSION}\"}" \
             -H "Content-Type: application/json"
    else
        log_with_timestamp "OS update failed."
        curl -X POST "http://localhost:7125/printer/gcode/script" \
             -d "{\"script\": \"_OS_UPDATE_ERROR\"}" \
             -H "Content-Type: application/json"
    fi
else
    log_with_timestamp "Update not needed."
fi
