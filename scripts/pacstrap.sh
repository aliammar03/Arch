#!/bin/bash

# Check if the script is being run as root
if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root."
    exit 1
fi

# Function to retry a command with a specified number of attempts
retry_command() {
    local command=$1
    local max_attempts=$2
    local attempt=1

    until $command; do
        if [[ $attempt -eq $max_attempts ]]; then
            echo "Failed to execute the command after $max_attempts attempts."
            exit 1
        fi

        echo "Attempt $attempt failed. Retrying..."
        ((attempt++))
        sleep 1
    done
}

# Update Time
timedatectl set-timezone Asia/Karachi

# Reflector
reflector --verbose --latest 20 --protocol http --sort rate --save /etc/pacman.d/mirrorlist

# Backup the original Pacman configuration file
cp /etc/pacman.conf /etc/pacman.conf.bak

# Enable parallel downloads, color, VerbosePkgLists, and ILoveCandy
sed -i 's/^#Color$/Color/' /etc/pacman.conf
sed -i 's/^#VerbosePkgLists$/VerbosePkgLists/' /etc/pacman.conf
sed -i '38s/.*/ILoveCandy/' /etc/pacman.conf
sed -i 's/^#ParallelDownloads = 5$/ParallelDownloads = 15/' /etc/pacman.conf

echo "Pacman has been configured successfully!"

# Restart Pacman's package database
pacman -Syy

# Install Base System with retry
retry_command "pacstrap /mnt base base-devel linux-zen linux-zen-headers linux-firmware intel-ucode reflector git sudo nano" 10

# Fstab
genfstab -U /mnt >> /mnt/etc/fstab

# Copy the isntaller scripts
cp -r ~/arch /mnt

# ArchChroot
arch-chroot /mnt
