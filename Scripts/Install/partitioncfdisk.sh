#!/bin/bash

# Check if the script is being run as root
if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root."
    exit 1
fi

# Function to partition the disk using cfdisk
partition_disk() {
    echo "Partitioning the disk using cfdisk..."
    cfdisk $disk
}

# Function to format a partition as ext4
format_partition() {
    echo "Formatting the partition as ext4..."
    mkfs.ext4 "${disk}${partition}"
}

# Function to mount a partition at the specified mount point
mount_partition() {
    echo "Mounting the partition at $mount_point..."
    mount "${disk}${partition}" $mount_point

    echo "Partition successfully mounted at $mount_point."
}

# Prompt for the disk to work with
echo "Please enter the disk to work with (e.g., /dev/sda):"
read disk

# Prompt for the action
echo "Please select an action:"
echo "1. Use cfdisk to partition the disk"
echo "2. Partition and format root"
echo "3. Mount boot"
echo "4. Mount home"
read -p "Enter the action number: " action

if [[ $action -eq 1 ]]; then
    # Use cfdisk to partition the disk
    partition_disk

elif [[ $action -eq 2 ]]; then
    # Partition and format a new partition
    partition_disk

    # Prompt for the partition number
    echo "Please enter the partition number to format (e.g., 1):"
    read partition

    format_partition
    mount_partition

elif [[ $action -eq 3 ]]; then
    # Mount an existing partition to /mnt/boot
    echo "Please enter the partition to mount (e.g., /dev/sda1):"
    read partition

    # Check if the partition exists
    if [[ ! -e $partition ]]; then
        echo "Error: Partition $partition does not exist."
        exit 1
    fi

    mount_point="/mnt/boot"
    mkdir -p $mount_point
    mount_partition

elif [[ $action -eq 4 ]]; then
    # Mount an existing partition to /mnt/home
    echo "Please enter the partition to mount (e.g., /dev/sda1):"
    read partition

    # Check if the partition exists
    if [[ ! -e $partition ]]; then
        echo "Error: Partition $partition does not exist."
        exit 1
    fi

    mount_point="/mnt/home"
    mkdir -p $mount_point
    mount_partition

else
    echo "Invalid action selected."
    exit 1
fi
