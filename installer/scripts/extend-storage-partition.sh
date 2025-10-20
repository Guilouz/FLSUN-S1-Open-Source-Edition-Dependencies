#!/bin/bash
# FLSUN S1 Open Source Edition

set -e

function extend_storage_partition_message(){
    top_line
    title 'Extend storage partition' "${cyan}"
    inner_line
    hr
    echo -e " │ This allows to extend storage partition to take advantage of   │"
    echo -e " │ the full storage.                                              │"
    hr
    bottom_line
}

function extend_storage_partition(){
    extend_storage_partition_message
    local yn
    while true; do
        read -p "${white}  Are you sure you want to extend ${cyan}storage partition${white}? (${cyan}y${white}/${cyan}n${white}): ${cyan}" yn
        case "${yn}" in
            Y|y)
                echo -e "${white}"
                missing_pkgs=()
                for pkg in e2fsprogs util-linux; do
                    if ! dpkg -s "$pkg" >/dev/null 2>&1; then
                        missing_pkgs+=("$pkg")
                    fi
                done
                if [ ${#missing_pkgs[@]} -ne 0 ]; then
                    info_msg "Updating packages list..."
                    echo
                    sudo apt update
                    echo
                    info_msg "Installing necessary packages..."
                    echo
                    sudo apt install -y "${missing_pkgs[@]}"
                    echo
                fi
                ROOT_PARTITION=$(findmnt -n -o SOURCE /)
                DEVICE=$(lsblk -no pkname $ROOT_PARTITION)
                PARTITION_NUMBER=$(echo $ROOT_PARTITION | grep -o '[0-9]*$')
                PARTITION_SIZE_AFTER=$(lsblk -no SIZE -b $ROOT_PARTITION | awk '{printf "%.2f GB", $1/1024/1024/1024}')
                AVAILABLE_SPACE=$(df -B1 --output=avail / | tail -1 | awk '{printf "%.2f GB", $1/1024/1024/1024}')
                USED_PERCENT=$(df --output=pcent / | tail -1 | tr -dc '0-9')
                FREE_PERCENT=$((100 - USED_PERCENT))
                info_msg "Extending GPT partition table..."
                sudo sgdisk -e /dev/$DEVICE >/dev/null 2>&1 || true
                echo
                info_msg "Resizing partition to use all available space..."
                sudo parted /dev/$DEVICE resizepart $PARTITION_NUMBER 100% --script >/dev/null 2>&1
                echo
                info_msg "Resizing filesystem..."
                sudo resize2fs -f $ROOT_PARTITION >/dev/null 2>&1
                echo
                ok_msg "Partition size after extension: $PARTITION_SIZE_AFTER with $AVAILABLE_SPACE available space ($FREE_PERCENT%)"
                return;;
            N|n)
                error_msg "Extension canceled!"
                return;;
            *)
                error_msg "Please select a correct choice!";;
        esac
    done
}
