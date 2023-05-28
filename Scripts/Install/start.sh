#!/bin/bash

# Check if the script is being run as root
if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root."
    exit 1
fi

# Update Time
timedatectl set-timezone Asia/Karachi

# Reflector
reflector --verbose --latest 20 --protocol http --sort rate --save /etc/pacman.d/mirrorlist

# Backup the original Pacman configuration file
cp /etc/pacman.conf /etc/pacman.conf.bak

# Enable parallel downloads, color, VerbosePkgLists, and ILoveCandy
sed -i 's/^#Color$/Color/' /etc/pacman.conf
sed -i 's/^#VerbosePkgLists$/VerbosePkgLists/' /etc/pacman.conf
sed -i 's/^#ILoveCandy$/ILoveCandy/' /etc/pacman.conf
sed -i 's/^#ParallelDownloads = 5$/ParallelDownloads = 15/' /etc/pacman.conf

echo "Pacman has been configured successfully!"

# Restart Pacman's package database
pacman -Syy

# Install Base System 
pacstrap -i /mnt base base-devel linux-zen linux-zen-headers linux-firmware intel-ucode reflector git sudo

#Fstab
genfstab -U /mnt >> /mnt/etc/fstab

