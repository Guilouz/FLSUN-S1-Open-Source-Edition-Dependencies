#!/bin/bash
# FLSUN S1 Open Source Edition

BASE_DIR="/home/pi/printer_data"
CONFIG_DIR="$BASE_DIR/config"
ZIP_CMD=$(command -v zip)
UNZIP_CMD=$(command -v unzip)

if [ -z "$ZIP_CMD" ]; then
  echo "Error: zip command not found. Please install it with this command via SSH: sudo apt install zip"
  exit 1
fi

if [ -z "$UNZIP_CMD" ]; then
  echo "Error: unzip command not found. Please install it with this command via SSH: sudo apt install unzip"
  exit 1
fi

backup_klipper() {
  if [ -f "$CONFIG_DIR"/backup_klipper.zip ]; then
    rm -f "$CONFIG_DIR"/backup_klipper.zip
  fi
  cd "$BASE_DIR"
  echo "Info: Compressing Klipper configuration files..."
  zip -r "$CONFIG_DIR"/backup_klipper.zip config
  echo "Info: Klipper configuration files have been saved successfully!"
}

restore_klipper() {
  if [ ! -f "$CONFIG_DIR"/backup_klipper.zip ]; then
    echo "Info: Please backup Klipper configuration files before restore!"
    exit 1
  fi
  cd "$BASE_DIR"
  mv config/backup_klipper.zip backup_klipper.zip
  if [ -f config/backup_moonraker.zip ]; then
    mv config/backup_moonraker.zip backup_moonraker.zip
  fi
  if [ -d config ]; then
    rm -rf config
  fi
  echo "Info: Restoring Klipper configuration files..."
  unzip backup_klipper.zip
  mv backup_klipper.zip config/backup_klipper.zip
  if [ -f backup_moonraker.zip ]; then
    mv backup_moonraker.zip config/backup_moonraker.zip
  fi
  echo "Info: Klipper configuration files have been restored successfully!"
}

backup_moonraker() {
  if [ -f "$CONFIG_DIR"/backup_moonraker.zip ]; then
    rm -f "$CONFIG_DIR"/backup_moonraker.zip
  fi
  cd "$BASE_DIR"
  echo "Info: Compressing Moonraker database..."
  zip -r "$CONFIG_DIR"/backup_moonraker.zip database
  echo "Info: Moonraker database has been saved successfully!"
}

restore_moonraker() {
  if [ ! -f "$CONFIG_DIR"/backup_moonraker.zip ]; then
    echo "Info: Please backup Moonraker database before restore!"
    exit 1
  fi
  cd "$BASE_DIR"
  mv config/backup_moonraker.zip backup_moonraker.zip
  if [ -d database ]; then
    rm -rf database
  fi
  echo "Info: Restoring Moonraker database..."
  unzip backup_moonraker.zip
  mv backup_moonraker.zip config/backup_moonraker.zip
  echo "Info: Moonraker database has been restored successfully!"
}

case "$1" in
  -backup_klipper)
    backup_klipper
    ;;
  -restore_klipper)
    restore_klipper
    ;;
  -backup_moonraker)
    backup_moonraker
    ;;
  -restore_moonraker)
    restore_moonraker
    ;;
  *)
    echo "Invalid argument. Usage: $0 [-backup_klipper | -restore_klipper | -backup_moonraker | -restore_moonraker]"
    exit 1
    ;;
esac
