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
format_partition_ext4() {
    echo "Formatting the partition as ext4..."
    mkfs.ext4 "${disk}${partition}"
}

# Function to format a partition as FAT32 and flag it as ESP using parted
format_partition_fat32_esp() {
    echo "Formatting the partition as FAT32 and flagging it as ESP..."
    parted -s $disk set $partition esp on
    mkfs.fat -F32 "${disk}${partition}"
}

# Function to mount a partition at the specified mount point
mount_partition() {
    echo "Mounting the partition at $mount_point..."
    mount "${disk}${partition}" $mount_point

    echo "Partition successfully mounted at $mount_point."
}

# Retrieve the list of disks in the system
disks=($(lsblk -o NAME -n -d))

# Prompt for the disk to work with
echo "Please select a disk:"
for ((i=0; i<${#disks[@]}; i++)); do
    echo "$((i+1)). ${disks[i]}"
done

read -p "Enter the disk number: " disk_number
selected_disk_index=$((disk_number-1))

# Check if the selected disk number is valid
if [[ $selected_disk_index -lt 0 || $selected_disk_index -ge ${#disks[@]} ]]; then
    echo "Invalid disk number."
    exit 1
fi

disk="/dev/${disks[selected_disk_index]}"

# Loop until the user chooses to exit
while true; do
    # Prompt for the action
    echo "Please select an action:"
    echo "1. Use cfdisk to partition the disk"
    echo "2. Partition and format root (ext4)"
    echo "3. Mount boot (format as FAT32 and flag as ESP)"
    echo "4. Mount home"
    echo "5. Exit"
    read -p "Enter the action number: " action

    if [[ $action -eq 1 ]]; then
        # Use cfdisk to partition the disk
        partition_disk

    elif [[ $action -eq 2 ]]; then
        # Retrieve the list of available partitions on the selected disk
        partitions=($(lsblk -o NAME -n -d $disk))

        # Prompt for the partition to format as ext4
        echo "Please select a partition to format as ext4:"
        for ((i=0; i<${#partitions[@]}; i++)); do
            echo "$((i+1)). ${partitions[i]}"
        done

        read -p "Enter the partition number: " partition_number
        selected_partition_index=$((partition_number-1))

        # Check if the selected partition number is valid
        if [[ $selected_partition_index -lt 0 || $selected_partition_index -ge ${#partitions[@]} ]]; then
            echo "Invalid partition number."
            continue
        fi

        partition="${partitions[selected_partition_index]}"

        # Prompt to format the partition
        read -p "Do you want to format the partition as ext4? (y/n): " format_choice
        if [[ $format_choice == "y" || $format_choice == "Y" ]]; then
            format_partition_ext4
        fi

        mount_point="/mnt/"
        mkdir -p $mount_point
        mount_partition


    elif [[ $action -eq 3 ]]; then
        # Prompt for the partition number
        echo "Please enter the partition number to format (e.g., 1):"
        read partition

        # Prompt to format the partition
        read -p "Do you want to format the partition as FAT32 and flag it as ESP? (y/n): " format_choice
        if [[ $format_choice == "y" || $format_choice == "Y" ]]; then
            format_partition_fat32_esp
        fi

        mount_point="/mnt/boot"
        mkdir -p $mount_point
        mount_partition

    elif [[ $action -eq 4 ]]; then
        # Prompt for the partition number
        echo "Please enter the partition number to format (e.g., 1):"
        read partition

        # Prompt to format the partition
        read -p "Do you want to format the partition as ext4? (y/n): " format_choice
        if [[ $format_choice == "y" || $format_choice == "Y" ]]; then
            format_partition_ext4
        fi

        mount_point="/mnt/home"
        mkdir -p $mount_point
        mount_partition

    elif [[ $action -eq 5 ]]; then
        # Exit the script
        echo "Exiting the script..."
        break

    else
        echo "Invalid action selected."
        continue
    fi

    echo "----------------------------------------"
done
