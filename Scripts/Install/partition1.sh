#!/bin/bash

# Check if the script is being run as root
if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root."
    exit 1
fi

# List available disks and partitions
lsblk

# Prompt user to enter the partition name
read -p "Enter the partition name (e.g., /dev/sda1): " partition

# Prompt user to confirm the partition selection
read -p "Are you sure you want to format and mount $partition? (y/n): " confirm
if [[ ! $confirm =~ ^[Yy]$ ]]; then
    echo "Operation aborted."
    exit 0
fi

# Prompt user to choose filesystem
read -p "Choose the filesystem type (ext4 or fat32): " filesystem

# Prompt user to enter the partition label
read -p "Enter the partition label: " label

# Prompt user to enter the mount point
read -p "Enter the mount point: " mount_point

# Format the partition with the chosen filesystem
if [[ $filesystem == "ext4" ]]; then
    mkfs.ext4 $partition
elif [[ $filesystem == "fat32" ]]; then
    mkfs.fat -F32 $partition
else
    echo "Invalid filesystem type. Operation aborted."
    exit 1
fi

# Set the partition label
e2label $partition $label

# Create mount point directory if it doesn't exist
if [[ ! -d $mount_point ]]; then
    mkdir -p $mount_point
fi

# Mount the partition
mount $partition $mount_point

echo "Partition $partition has been formatted with $filesystem, labeled as $label, and mounted on $mount_point."

exit 0

