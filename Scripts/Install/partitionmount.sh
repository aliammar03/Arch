#!/bin/bash

# Check if the script is being run as root
if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root."
    exit 1
fi

# Function to format, label, and mount a partition
format_label_mount_partition() {
    local partition=$1
    local filesystem=$2
    local label=$3
    local mount_point=$4

    # Format the partition with the chosen filesystem
    if [[ $filesystem == "ext4" ]]; then
        mkfs.ext4 $partition
    elif [[ $filesystem == "fat32" ]]; then
        mkfs.fat -F32 $partition
    else
        echo "Invalid filesystem type. Skipping partition $partition."
        return
    fi

    # Set the partition label
    e2label $partition $label

    # Create mount point directory if it doesn't exist
    if [[ ! -d $mount_point ]]; then
        mkdir -p $mount_point
        echo "Mount point directory $mount_point created."
    fi

    # Mount the partition
    mount $partition $mount_point

    echo "Partition $partition has been formatted with $filesystem, labeled as $label, and mounted on $mount_point."
}

# List available disks and partitions
lsblk

while true; do
    # Prompt user to enter the partition name
    read -p "Enter the partition name (e.g., /dev/sda1), or 'q' to quit: " partition
    if [[ $partition == "q" ]]; then
        break
    fi

    # Prompt user to confirm the partition selection
    read -p "Are you sure you want to format and mount $partition? (y/n): " confirm
    if [[ ! $confirm =~ ^[Yy]$ ]]; then
        echo "Skipping partition $partition."
        continue
    fi

    # Prompt user to choose filesystem
    read -p "Choose the filesystem type (ext4 or fat32): " filesystem

    # Prompt user to enter the partition label
    read -p "Enter the partition label: " label

    # Prompt user to enter the mount point
    read -p "Enter the mount point: " mount_point

    # Format, label, and mount the partition
    format_label_mount_partition "$partition" "$filesystem" "$label" "$mount_point"
done

exit 0
