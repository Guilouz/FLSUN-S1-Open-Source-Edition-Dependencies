#!/bin/bash
# FLSUN S1 Open Source Edition

MOUNT_POINT="/mnt/clone"
MMC_PARTITION="/dev/mmcblk0p6"

set -e

function ssh_access_message(){
    top_line
    title 'Restore SSH access for Stock OS' "${cyan}"
    inner_line
    hr
    echo -e " │ This allows to restore SSH access when you are running FLSUN's │"
    echo -e " │ Stock OS.                                                      │"
    hr
    bottom_line
}

function cleanup() {
    sudo umount "$MOUNT_POINT/dev" >/dev/null 2>&1 || true
    sudo umount "$MOUNT_POINT/proc" >/dev/null 2>&1 || true
    sudo umount "$MOUNT_POINT/sys" >/dev/null 2>&1 || true
    sudo umount "$MOUNT_POINT/run" >/dev/null 2>&1 || true
    sudo umount "$MOUNT_POINT" >/dev/null 2>&1 || true
}

function restore_ssh_access(){
    ssh_access_message
    local yn
    while true; do
        read -p "${white}  Are you sure you want to restore ${cyan}SSH access for Stock OS${white}? (${cyan}y${white}/${cyan}n${white}): ${cyan}" yn
        case "${yn}" in
            Y|y)
                echo -e "${white}"
				info_msg "Mounting volumes..."
        		if [ ! -d "$MOUNT_POINT" ]; then
					if ! sudo mkdir -p "$MOUNT_POINT" 2>/dev/null; then
                        error_msg "Error: Failed to create mount point directory!"
                        exit 1
                    fi
				fi
        		if ! sudo mount "$MMC_PARTITION" "$MOUNT_POINT" 2>/dev/null; then
            		error_msg "Error: Failed to mount $MOUNT_POINT!"
            		cleanup
            		exit 1
        		fi
        		echo
        		info_msg "Configuring SSH Header files..."
                sudo cp "/home/pi/flsun-os/installer/files/10-uname" "$MOUNT_POINT/etc/update-motd.d/10-uname"
                sudo chmod 755 "$MOUNT_POINT/etc/update-motd.d/10-uname"
                echo "" | sudo tee "$MOUNT_POINT/etc/motd" >/dev/null 2>&1
        		sed -i 's/^#PrintLastLog yes/PrintLastLog no/' "$MOUNT_POINT/etc/ssh/sshd_config" >/dev/null 2>&1
        		if ! sudo mount --bind /dev "$MOUNT_POINT/dev" >/dev/null 2>&1; then
                    error_msg "Error: Failed to mount $MOUNT_POINT/dev!"
                    cleanup
                    exit 1
                fi
                if ! sudo mount --bind /proc "$MOUNT_POINT/proc" >/dev/null 2>&1; then
                    error_msg "Error: Failed to mount $MOUNT_POINT/proc!"
                    cleanup
                    exit 1
                fi
                if ! sudo mount --bind /sys "$MOUNT_POINT/sys" >/dev/null 2>&1; then
                    error_msg "Error: Failed to mount $MOUNT_POINT/sys!"
                    cleanup
                    exit 1
                fi
                if ! sudo mount --bind /run "$MOUNT_POINT/run" >/dev/null 2>&1; then
                    error_msg "Error: Failed to mount $MOUNT_POINT/run!"
                    cleanup
                    exit 1
                fi
                echo
                info_msg "Fixing hosts file..."
                MOUNTED_HOSTNAME=$(sudo cat "$MOUNT_POINT/etc/hostname")
                if [ "$MOUNTED_HOSTNAME" == "FLSunS1Pro" ]; then
                    sudo sed -i 's/127.0.1.1\s\+flsun/127.0.1.1   FLSunS1Pro/' "$MOUNT_POINT/etc/hosts"
                else
                    sudo sed -i 's/127.0.1.1\s\+flsun/127.0.1.1   FLSunS1/' "$MOUNT_POINT/etc/hosts"
                fi
				echo
				info_msg "Updating APT sources list..."
				echo "" | sudo tee "$MOUNT_POINT/etc/apt/sources.list" >/dev/null 2>&1
        		sudo tee "$MOUNT_POINT/etc/apt/sources.list" <<EOF >/dev/null 2>&1
deb http://deb.debian.org/debian buster main contrib non-free
deb http://deb.debian.org/debian buster-updates main contrib non-free
deb http://archive.debian.org/debian buster-backports main contrib non-free
deb http://security.debian.org/debian-security/ buster/updates main contrib non-free
EOF
        		echo
                info_msg "Changing accounts passwords..."
                sudo chroot "$MOUNT_POINT" /bin/bash <<EOF >/dev/null 2>&1
echo "root:flsun" | chpasswd || exit 1
echo "pi:flsun" | chpasswd || exit 1
EOF
                if ! sudo chroot "$MOUNT_POINT" /bin/bash -c "dpkg -s libssl1.1" >/dev/null 2>&1; then
                    echo
                    info_msg "Installing missing dependencies..."
                    sudo chroot "$MOUNT_POINT" /bin/bash <<EOF >/dev/null 2>&1
apt update
apt install -y libssl1.1=1.1.1n-0+deb10u6
EOF
                fi
        		echo
        		info_msg "Reinstalling openssh-server..."
        		sudo chroot "$MOUNT_POINT" /bin/bash <<EOF >/dev/null 2>&1
apt install --reinstall openssh-server -y
dpkg --configure -a
EOF
				echo
				info_msg "Unmounting volumes..."
				cleanup
                ok_msg "SSH access for Stock OS has been restored!"
                echo -e "    You can now login from Stock OS with ${yellow}root${white} or ${yellow}pi${white} users and password: ${yellow}flsun${white}"
                echo
                return;;
            N|n)
                error_msg "Restoration canceled!"
                return;;
            *)
                error_msg "Please select a correct choice!";;
        esac
    done
}
