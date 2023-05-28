#!/bin/bash

# Check if the script is being run as root
if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root."
    exit 1
fi

# Function to format a partition as ext4 and label it
format_partition() {
    echo "Formatting the partition as ext4..."
    mkfs.ext4 -L $label "${disk}${partition}"
    echo "Partition successfully formatted as ext4 and labeled as $label."
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
echo "1. Partition the disk using cfdisk"
echo "2. Partition and format a new partition"
echo "3. Mount an existing partition to /mnt/boot"
echo "4. Mount an existing partition to /mnt/home"
read -p "Enter the action number: " action

if [[ $action -eq 1 ]]; then
    # Partition the disk using cfdisk
    echo "Partitioning the disk using cfdisk..."
    cfdisk $disk

elif [[ $action -eq 2 ]]; then
    # Partition and format a new partition
    echo "Please enter the partition to format and mount (e.g., /dev/sda1):"
    read partition

    # Check if the partition exists
    if [[ ! -e $partition ]]; then
        echo "Error: Partition $partition does not exist."
        exit 1
    fi

    # Prompt for the label
    echo "Please enter the label for the partition:"
    read label

    format_partition
    mount_point="/mnt"
    mkdir -p $mount_point
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

    echo -n "Do you want to format the partition before mounting? (yes/no): "
    read answer

    if [[ $answer == "yes" ]]; then
        # Prompt for the label
        echo "Please enter the label for the partition:"
        read label

        format_partition
    fi

    mount_point="/mnt/home"
    mkdir -p $mount_point
    mount_partition

else
    echo "Invalid action selected."
    exit 1
fi
