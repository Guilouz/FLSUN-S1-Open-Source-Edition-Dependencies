#!/bin/sh
# FLSUN S1 Open Source Edition

touch /dev/shm/drying_box.json
chmod 664 /dev/shm/drying_box.json
touch /dev/shm/drying_box_temp
chmod 664 /dev/shm/drying_box_temp

while true;
do
	stty -F /dev/ttyS4 19200
	read INPUT </dev/ttyS4
	echo "$INPUT" > /dev/shm/drying_box.json
	temp=$(echo $INPUT | grep -o '"temperature":[^,]*' | grep -o '[^:]*$')
	temp=$(echo "$temp" | awk '{print $1 * 1000}')
	echo "$temp" > /dev/shm/drying_box_temp
done
