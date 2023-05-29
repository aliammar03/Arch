#!/bin/bash

# Check if the script is being run as root
if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root."
    exit 1
fi

# Make all the scripts executable
chmod +x ./*
chmod +x ./apps/*
chmod +x ./scripts/*

# Function to partition the disk using cfdisk
partition_disk() {
    echo "Partitioning the disk using cfdisk..."
    cfdisk $disk
}

# Function to format a partition as ext4
format_partition_ext4() {
    echo "Formatting the partition as ext4..."
    if [[ $disk_type == "nvme" ]]; then
        mkfs -t ext4 "${disk}p${partition}"
    else
        mkfs -t ext4 "${disk}${partition}"
    fi
}

# Function to format a partition as FAT32 and flag it as ESP using parted
format_partition_fat32_esp() {
    echo "Formatting the partition as FAT32 and flagging it as ESP..."
    if [[ $disk_type == "nvme" ]]; then
        parted -s $disk set ${partition} esp on
        mkfs.fat -F 32 "${disk}p${partition}"
    else
        parted -s $disk set ${partition} esp on
        mkfs.fat -F 32 "${disk}${partition}"
    fi
}

# Function to mount a partition at the specified mount point
mount_partition() {
    echo "Mounting the partition at $mount_point..."
    if [[ $disk_type == "nvme" ]]; then
        mount "${disk}p${partition}" $mount_point
    else
        mount "${disk}${partition}" $mount_point
    fi

    echo "Partition successfully mounted at $mount_point."
}

# Function to scan disk for partitions and allow the user to choose one
scan_disk_for_partitions() {
    echo "Scanning the disk for partitions..."
    lsblk -f $disk

    echo "Please enter the partition number to select (e.g., 1):"
    read partition
}

# Function to view the current disk structure
view_disk_structure() {
    echo "Current disk structure:"
    lsblk -f
    echo "----------------------------------------"
}

# Function to launch the pacstrap.sh script
launch_pacstrap_script() {
    echo "Launching the pacstrap.sh script..."
    chmod +x ./scripts/pacstrap.sh
    ./scripts/pacstrap.sh
}

# Retrieve the list of disks in the system
disks=($(lsblk -o NAME -n -d | grep -E "^(nvme|sda|sdb)"))

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
disk_type=$(echo "${disks[selected_disk_index]}" | cut -c 1-4)

# Loop until the user chooses to exit
while true; do
    # Prompt for the action
    echo "Please select an action:"
    echo "1. Use cfdisk to partition the disk"
    echo "2. Prepare root"
    echo "3. Prepare boot"
    echo "4. Prepare home"
    echo "5. View current disk structure"
    echo "6. Start Pacstrap"
    echo "7. ArchChroot"    
    echo "8. Exit"
    read -p "Enter the action number: " action

    if [[ $action -eq 1 ]]; then
        # Use cfdisk to partition the disk
        partition_disk

    elif [[ $action -eq 2 ]]; then
        # Prompt for partition selection
        scan_disk_for_partitions

        # Prompt to format the partition
        read -p "Do you want to format the partition as ext4? (y/n): " format_choice
        if [[ $format_choice == "y" || $format_choice == "Y" ]]; then
            format_partition_ext4
        fi

        mount_point="/mnt/"
        mkdir -p $mount_point
        mount_partition

    elif [[ $action -eq 3 ]]; then
        # Prompt for partition selection
        scan_disk_for_partitions

        # Prompt to format the partition
        read -p "Do you want to format the partition as FAT32 and flag it as ESP? (y/n): " format_choice
        if [[ $format_choice == "y" || $format_choice == "Y" ]]; then
            format_partition_fat32_esp
        fi

        mount_point="/mnt/boot"
        mkdir -p $mount_point
        mount_partition

    elif [[ $action -eq 4 ]]; then
        # Prompt for partition selection
        scan_disk_for_partitions

        # Prompt to format the partition
        read -p "Do you want to format the partition as ext4? (y/n): " format_choice
        if [[ $format_choice == "y" || $format_choice == "Y" ]]; then
            format_partition_ext4
        fi

        mount_point="/mnt/home"
        mkdir -p $mount_point
        mount_partition
        
    elif [[ $action -eq 5 ]]; then
        # View current disk structure
        view_disk_structure

    elif [[ $action -eq 6 ]]; then
        # Launch the install.sh script
        launch_pacstrap_script

    elif [[ $action -eq 7 ]]; then
        # ArchChroot
        echo "ArchChrooting into new install"
        arch-chroot /mnt
        
    elif [[ $action -eq 8 ]]; then
        # Exit the script
        echo "Exiting the script..."
        break

    else
        echo "Invalid action selected."
        continue
    fi

    echo "----------------------------------------"
done
