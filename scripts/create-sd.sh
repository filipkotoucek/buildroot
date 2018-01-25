#!/bin/bash
if [ "$(whoami)" != "root" ]; then
    echo "You must be root to do this"
    exit
fi

BASEDIR=$(dirname $0)
echo "Script location: ${BASEDIR}"

echo "creating bootable SD card from buildroots image"
dd if=${BASEDIR}/../output/images/sdcard.img of=/dev/mmcblk0

