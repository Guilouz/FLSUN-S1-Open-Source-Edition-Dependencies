#!/bin/sh
# FLSUN S1 Open Source Edition

systemctl stop drying-box.service
stty -F /dev/ttyS4 19200
printf "RES\r\n" >/dev/ttyS4
read INPUT </dev/ttyS4
echo "$INPUT"
systemctl start drying-box.service
