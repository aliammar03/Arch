#!/bin/bash

# Check if the script is being run as root
if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root."
    exit 1
fi

# Install systemd-boot
bootctl install

# Prompt the user to enter the root partition
read -p "Enter the root partition (e.g., /dev/sda2): " root_partition

# Check if the specified partition exists
if [[ ! -e $root_partition ]]; then
    echo "Specified root partition does not exist. Please try again."
    exit 1
fi

# Get the UUID of the root partition
root_uuid=$(blkid -s UUID -o value $root_partition)

# Determine the kernel package name
kernel_package=""
if pacman -Qi linux-zen &> /dev/null; then
    kernel_package="linux-zen"
elif pacman -Qi linux-lts &> /dev/null; then
    kernel_package="linux-lts"
elif pacman -Qi linux &> /dev/null; then
    kernel_package="linux"
else
    echo "No supported kernel packages (linux, linux-zen, or linux-lts) found. Exiting."
    exit 1
fi

# Create the bootloader entries
cat << EOF > /boot/loader/entries/arch.conf
title   Arch Linux
linux   /vmlinuz-$kernel_package
initrd  /initramfs-$kernel_package.img
options root=UUID=$root_uuid rw quiet splash
EOF

cat << EOF > /boot/loader/loader.conf
default arch.conf
timeout 3
EOF

echo "Systemd-boot has been installed successfully."
echo "Bootloader entries have been created with root partition: $root_partition."
echo "Using $kernel_package as the kernel."

exit 0
