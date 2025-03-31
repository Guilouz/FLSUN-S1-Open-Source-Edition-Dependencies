#!/bin/bash
# FLSUN S1 Open Source Edition

BASE_DIR="/home/pi/printer_data"
CONFIG_DIR="$BASE_DIR/config"
ZIP_CMD=$(command -v zip)
UNZIP_CMD=$(command -v unzip)

set -e

function backup_klipper_message(){
    top_line
    title 'Backup Klipper configuration files' "${cyan}"
    inner_line
    hr
    echo -e " │ This allows to backup Klipper configuration files to a         │"
    echo -e " │ backup_klipper.zip compressed file.                            │"
    hr
    bottom_line
}

function restore_klipper_message(){
    top_line
    title 'Restore Klipper configuration files' "${cyan}"
    inner_line
    hr
    echo -e " │ This allows to restore Klipper configuration files from a      │"
    echo -e " │ backup_klipper.zip compressed file.                            │"
    hr
    bottom_line
}

function backup_moonraker_message(){
    top_line
    title 'Backup Moonraker database' "${cyan}"
    inner_line
    hr
    echo -e " │ This allows to backup Moonraker database to a                  │"
    echo -e " │ backup_moonraker.zip compressed file.                          │"
    hr
    bottom_line
}

function restore_moonraker_message(){
    top_line
    title 'Restore Moonraker database' "${cyan}"
    inner_line
    hr
    echo -e " │ This allows to restore Moonraker database from a               │"
    echo -e " │ backup_moonraker.zip compressed file.                          │"
    hr
    bottom_line
}

function check_zip(){
    if [ -z "$ZIP_CMD" ]; then
        info_msg "Installing zip package..."
        echo
        sudo apt update > /dev/null 2>&1
        sudo apt install zip -y > /dev/null 2>&1
        echo
    fi
}

function check_unzip(){
    if [ -z "$UNZIP_CMD" ]; then
        info_msg "Installing unzip package..."
        echo
        sudo apt update > /dev/null 2>&1
        sudo apt install unzip -y > /dev/null 2>&1
        echo
    fi
}

function backup_klipper(){
    backup_klipper_message
    local yn
    while true; do
        backup_msg "Klipper configuration files" yn
        case "${yn}" in
            Y|y)
                echo -e "${white}"
                check_zip
                if [ -f "$CONFIG_DIR"/backup_klipper.zip ]; then
                    rm -f "$CONFIG_DIR"/backup_klipper.zip > /dev/null 2>&1
                fi
                cd "$BASE_DIR"
                info_msg "Compressing Klipper configuration files..."
                zip -r "$CONFIG_DIR"/backup_klipper.zip config > /dev/null 2>&1
                ok_msg "Klipper configuration files have been saved successfully!"
                return;;
            N|n)
                error_msg "Backup canceled!"
                return;;
            *)
                error_msg "Please select a correct choice!";;
        esac
    done
}

function restore_klipper(){
    restore_klipper_message
    local yn
    while true; do
        restore_msg "Klipper configuration files" yn
        case "${yn}" in
            Y|y)
                echo -e "${white}"
                check_unzip
                cd "$BASE_DIR"
                mv config/backup_klipper.zip backup_klipper.zip > /dev/null 2>&1
                if [ -f config/backup_moonraker.zip ]; then
                    mv config/backup_moonraker.zip backup_moonraker.zip > /dev/null 2>&1
                fi
                if [ -d config ]; then
                    rm -rf config > /dev/null 2>&1
                fi
                info_msg "Restoring Klipper configuration files..."
                echo
                unzip backup_klipper.zip > /dev/null 2>&1
                mv backup_klipper.zip config/backup_klipper.zip > /dev/null 2>&1
                if [ -f backup_moonraker.zip ]; then
                    mv backup_moonraker.zip config/backup_moonraker.zip > /dev/null 2>&1
                fi
                info_msg "Restarting Klipper service..."
                restart_klipper
                ok_msg "Klipper configuration files have been restored successfully!"
                return;;
            N|n)
                error_msg "Restoration canceled!"
                return;;
            *)
                error_msg "Please select a correct choice!";;
        esac
    done
}

function backup_moonraker(){
    backup_moonraker_message
    local yn
    while true; do
        backup_msg "Moonraker database" yn
        case "${yn}" in
            Y|y)
                echo -e "${white}"
                check_zip
                if [ -f "$CONFIG_DIR"/backup_moonraker.zip ]; then
                    rm -f "$CONFIG_DIR"/backup_moonraker.zip > /dev/null 2>&1
                fi
                cd "$BASE_DIR"
                info_msg "Compressing Moonraker database..."
                zip -r "$CONFIG_DIR"/backup_moonraker.zip database > /dev/null 2>&1
                ok_msg "Moonraker database has been saved successfully!"
                return;;
            N|n)
                error_msg "Backup canceled!"
                return;;
            *)
                error_msg "Please select a correct choice!";;
        esac
    done
}

function restore_moonraker(){
    restore_moonraker_message
    local yn
    while true; do
        restore_msg "Moonraker database" yn
        case "${yn}" in
            Y|y)
                echo -e "${white}"
                check_unzip
                cd "$BASE_DIR"
                mv config/backup_moonraker.zip backup_moonraker.zip > /dev/null 2>&1
                if [ -d database ]; then
                    rm -rf database > /dev/null 2>&1
                fi
                info_msg "Restoring Moonraker database..."
                echo
                unzip backup_moonraker.zip > /dev/null 2>&1
                mv backup_moonraker.zip config/backup_moonraker.zip
                info_msg "Restarting Moonraker service..."
                restart_moonraker
                ok_msg "Moonraker database has been restored successfully!"
                return;;
            N|n)
                error_msg "Restoration canceled!"
                return;;
            *)
                error_msg "Please select a correct choice!";;
        esac
    done
}
