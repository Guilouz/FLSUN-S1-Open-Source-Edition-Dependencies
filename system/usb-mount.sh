#!/bin/bash
# FLSUN S1 Open Source Edition

ACTION=$1
DEVBASE=$2
DEVICE="/dev/${DEVBASE}"
MOUNT_POINT=$(/bin/mount | /bin/grep ${DEVICE} | /usr/bin/awk '{ print $3 }')
TARGET_DIR_BASE="/home/pi/printer_data/gcodes/USB-DISK"

usb_disk_number() {
    local num=1
    while [[ -d "${TARGET_DIR_BASE}-${num}" ]]; do
        num=$((num + 1))
    done
    echo "${TARGET_DIR_BASE}-${num}"
}

mounted_usb_disk() {
    for dir in ${TARGET_DIR_BASE}-*; do
        if [[ $(/bin/mount | /bin/grep ${dir}) && $(/bin/mount | /bin/grep ${DEVICE}) ]]; then
            echo "${dir}"
            return
        fi
    done
    echo ""
}

case "${ACTION}" in
    add)
        if [[ -n ${MOUNT_POINT} ]]; then exit 1; fi
        ID_FS_TYPE=$(/sbin/blkid -o value -s TYPE ${DEVICE})
        OPTS="rw,relatime"
        MOUNT_CMD="/bin/mount"
        case "${ID_FS_TYPE}" in
            vfat)
                OPTS+=",users,gid=100,umask=000,shortname=mixed,utf8=1,flush"
                ;;
            ntfs)
                OPTS+=",users,gid=100,umask=000"
                ;;
            exfat)
                OPTS+=",users,gid=100,umask=000"
                MOUNT_CMD="mount.exfat-fuse"
                ;;
        esac
        TARGET_DIR=$(usb_disk_number)
        mkdir -p ${TARGET_DIR}
        if ! ${MOUNT_CMD} -o ${OPTS} ${DEVICE} ${TARGET_DIR}; then exit 1; fi
        ;;
    remove)
        TARGET_DIR=$(mounted_usb_disk)
        if [[ -n ${TARGET_DIR} && ${MOUNT_POINT} == ${TARGET_DIR} ]]; then
            /bin/umount -l ${DEVICE}
            rmdir ${TARGET_DIR}
        fi
        /home/pi/flsun-os/system/usb-mount-delete-unused.sh
        ;;
esac
