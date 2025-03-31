#!/bin/bash
# FLSUN S1 Open Source Edition

white=`echo -en "\033[m"`
darkred=`echo -en "\033[31m"`

if [ "$EUID" -eq 0 ]; then
    echo "${darkred}WARNING: This script must not be run as root!${white}"
    echo
    exit 1
fi
set -e
clear

SCRIPT_FOLDER="$(dirname "$(readlink -f "$0")")"
for script in "${SCRIPT_FOLDER}/scripts/"*.sh; do . "${script}"; done

set_colors
main_menu
