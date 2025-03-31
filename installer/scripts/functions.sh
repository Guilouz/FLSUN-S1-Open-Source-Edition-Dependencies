#!/bin/bash
# FLSUN S1 Open Source Edition

set -e

function set_colors() {
    if [ -t 1 ]; then
        white=`echo -en "\033[m"`
        cyan=`echo -en "\033[0;36m"`
        yellow=`echo -en "\033[1;33m"`
        green=`echo -en "\033[01;32m"`
        darkred=`echo -en "\033[31m"`
      else
        white=""
        cyan=""
        yellow=""
        green=""
        darkred=""
      fi
}

function top_line() {
    echo -e "${white}"
    echo -e " ┌────────────────────────────────────────────────────────────────┐"
}

function hr() {
    echo -e " │                                                                │"
}

function inner_line() {
    echo -e " ├────────────────────────────────────────────────────────────────┤"
}

function bottom_line() {
    echo -e " └────────────────────────────────────────────────────────────────┘"
    echo -e "${white}"
}

function blank_line() {
    echo -e " "
}

function title() {
    local text="$1"
    local color="$2"
    local max_length=64
    local text_length=$(echo -n "$text" | wc -m)
    local total_padding=$((max_length - text_length))
    local padding_left=$((total_padding / 2))
    local padding_right=$((total_padding - padding_left))
    printf " │%*s${color}%s${white}%*s│\n" $padding_left '' "$text" $padding_right ''
}

function main_menu_option() {
    local menu_number=$1
    local menu_text1=$2
    local menu_text2=$3
    local max_length=57
    local total_text_length=$(( ${#menu_text1} + ${#menu_text2} ))
    local padding=$((max_length - total_text_length))
    printf " │   ${cyan}${menu_number}${white}) ${menu_text1} ${menu_text2}%-${padding}s${white}│\n" ''
}

function menu_option() {
    local menu_number=$1
    local menu_text1=$2
    local menu_text2=$3
    local max_length=63
    local total_text_length=$(( ${#menu_text1} + ${#menu_text2} + ${#menu_number} + 4 ))
    local padding=$((max_length - total_text_length))
    printf " │  ${cyan}${menu_number}${white}) ${white}${menu_text1} ${menu_text2}%-${padding}s│\n" ''
}

function bottom_menu_option() {
    local menu_number=$1
    local menu_text=$2
    local color=$3
    local max_length=58
    local padding=$((max_length - ${#menu_text}))
    printf " │   $color${menu_number}${white}) ${white}${menu_text}%-${padding}s${white}│\n" ''
}

function install_msg() {
    read -p "${white}  Are you sure you want to install ${cyan}${1}${white}? (${cyan}y${white}/${cyan}n${white}): ${cyan}" $2
}

function remove_msg() {
    read -p "${white}  Are you sure you want to remove ${cyan}${1}${white}? (${cyan}y${white}/${cyan}n${white}): ${cyan}" $2
}

function restore_msg() {
    read -p "${white}  Are you sure you want to restore ${cyan}${1}${white}? (${cyan}y${white}/${cyan}n${white}): ${cyan}" $2
}

function backup_msg() {
    read -p "${white}  Are you sure you want to backup ${cyan}${1}${white}? (${cyan}y${white}/${cyan}n${white}): ${cyan}" $2
}

function ok_msg() {
    echo
    echo -e "${white}${green}  ✓ ${1}${white}"
    echo
}

function error_msg() {
    echo
    echo -e "${white}${darkred}  ✗ ${1}${white}"
    echo
}

function info_msg() {
    echo -e "${white}${yellow}  Info: ${white}${1}"
}

function run() {
    clear
    $1
    $2
}

function edit_config() {
  local action="$1"
  local item="$2"
  local file="$3"
  "${SCRIPT_FOLDER}/scripts/edit-config.py" "$action" "$item" "$file"
}

function restart_moonraker() {
    sudo systemctl restart moonraker > /dev/null 2>&1
    sleep 1
}

function restart_klipper() {
    sudo systemctl restart klipper > /dev/null 2>&1
}

function restart_klipperscreen() {
    sudo systemctl restart KlipperScreen > /dev/null 2>&1
}

function restart_webcamd() {
    sudo systemctl restart webcamd > /dev/null 2>&1
}

function stop_klipper() {
    sudo systemctl stop klipper > /dev/null 2>&1
}

function start_klipper() {
    sudo systemctl start klipper > /dev/null 2>&1
}
