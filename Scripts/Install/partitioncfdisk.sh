#!/bin/bash

# Check if the script is being run as root
if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root."
    exit 1
fi

# Function to mount a partition
mount_partition() {
    local partition=$1
    local mount_point=$2

    # Create mount point directory if it doesn't exist
    if [[ ! -d $mount_point ]]; then
        mkdir -p $mount_point
        echo "Mount point directory $mount_point created."
    fi

    # Mount the partition
    mount $partition $mount_point

    echo "Partition $partition has been mounted on $mount_point."
}

# Function to format, label, and mount a partition
format_label_mount_partition() {
    local partition=$1
    local filesystem=$2
    local label=$3
    local mount_point=$4

    # Check if the partition exists
    if [[ ! -b $partition ]]; then
        echo "Partition $partition does not exist. Skipping."
        return
    fi

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

    # Mount the partition
    mount_partition $partition $mount_point
}

# Function to partition a disk using cfdisk
partition_disk() {
    local disk=$1

    echo "Partitioning disk $disk using cfdisk..."
    cfdisk $disk
}

# List available disks
lsblk

while true; do
    echo "1. Partition a disk using cfdisk"
    echo "2. Format, label, and mount a partition"
    echo "3. Mount a partition (without formatting)"
    echo "4. Quit"

    # Prompt user for action
    read -p "Enter your choice (1, 2, 3, or 4): " choice

    case $choice in
        1)
            # Prompt user to enter the disk name
            read -p "Enter the disk name (e.g., /dev/sda): " disk

            # Partition the disk using cfdisk
            partition_disk "$disk"
            ;;
        2)
            # Prompt user to enter the partition name
            read -p "Enter the partition name (e.g., /dev/sda1), or 'q' to go back: " partition
            if [[ $partition == "q" ]]; then
                continue
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
            format_label_mount_partition "$partition" "$filesystem"
