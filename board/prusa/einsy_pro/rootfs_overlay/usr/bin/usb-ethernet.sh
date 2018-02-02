#!/bin/sh

# Based off:
# https://github.com/RobertCNelson/boot-scripts/blob/master/boot/am335x_evm.sh

# Assume some defaults
SERIAL_NUMBER="1234BBBK5678"
PRODUCT="am335x_evm"
manufacturer="ti.com"

# Read serial numberfrom the eerpom
eeprom="/sys/bus/i2c/devices/0-0050/eeprom"
if [ -f ${eeprom} ] ; then
	SERIAL_NUMBER=$(hexdump -e '8/1 "%c"' ${eeprom} -n 28 | cut -b 17-28)
	PRODUCT="BeagleBoneBlack"
	manufacturer="BeagleBoard.org"
fi

echo "SERIAL_NUMBER = ${SERIAL_NUMBER}"
echo "PRODUCT = ${PRODUCT}"

#save location of MAC address, otherwise exit
mac_address="/proc/device-tree/ocp/ethernet@4a100000/slave@4a100300/mac-address"
[ -r "$mac_address" ] || exit 0

#save MAC address as address of this device
dev_addr=$(/usr/bin/hexdump -v -e '5/1 "%02X:" 1/1 "%02X"' "$mac_address")
echo "dev_addr = ${dev_addr}"

#define static MAC for host PC. Swap last digit to 0
host_addr="${dev_addr:0:-1}0"
echo "host_addr = ${host_addr}"

# Set the g_multi parameters (read-write, removable)
g_defaults="cdrom=0 ro=0 stall=0 removable=1 nofua=1"
g_product="iSerialNumber=${SERIAL_NUMBER} iManufacturer=${manufacturer} iProduct=${PRODUCT}"
g_network="dev_addr=${dev_addr} host_addr=${host_addr}"
g_storage="file=/dev/mmcblk0p2"

#start g_multi module. It starts usb0 interface and mounts rootfs as removable device
modprobe g_multi ${g_storage} ${g_defaults} ${g_product} ${g_network}
#modprobe g_ether ${g_network}

# Bring up the USB network interface
ifdown usb0
ifup usb0
