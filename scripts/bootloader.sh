#!/bin/bash

# Check if the script is being run as root
if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root."
    exit 1
fi

# Install systemd-boot
bootctl install

# Scan partitions and display them for selection
echo "Scanning partitions..."
partitions=()
mapfile -t partitions < <(lsblk -nrdo NAME)
echo "Available partitions:"
for index in "${!partitions[@]}"; do
    echo "$(($index + 1)). ${partitions[$index]}"
done

# Prompt the user to choose the root partition
read -p "Enter the number of the root partition (e.g., 1): " root_partition_number

# Validate the user input
if [[ ! $root_partition_number =~ ^[0-9]+$ ]] || [[ $root_partition_number -lt 1 ]] || [[ $root_partition_number -gt ${#partitions[@]} ]]; then
    echo "Invalid root partition number. Exiting."
    exit 1
fi

# Get the selected root partition
root_partition=${partitions[$(($root_partition_number - 1))]}

# Check if the specified partition exists
if [[ ! -e /dev/"$root_partition" ]]; then
    echo "Specified root partition does not exist. Exiting."
    exit 1
fi

# Get the UUID of the root partition
root_uuid=$(blkid -s UUID -o value /dev/"$root_partition")

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
echo "Bootloader entries have been created with root partition: /dev/$root_partition."
echo "Using $kernel_package as the kernel."

exit 0
