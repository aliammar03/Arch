#!/bin/bash

# Check if the script is being run as root
if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root."
    exit 1
fi

# Function to generate and set the locale
generate_locale() {
    local locale=$1

    # Uncomment the locale in the locale.gen file
    sed -i "s/^#$locale/$locale/" /etc/locale.gen

    # Generate the locale
    locale-gen

    # Set the generated locale as the system default
    echo "LANG=$locale" > /etc/locale.conf

    echo "Locale $locale has been generated and set successfully."
}

# Function to set the clock
set_clock() {
    local timezone=$1

    # Set the timezone by creating a symlink
    ln -sf "/usr/share/zoneinfo/$timezone" /etc/localtime

    # Update the hardware clock
    hwclock --systohc

    echo "Clock has been set to the timezone $timezone."
}

# Prompt the user to enter the desired locale
read -p "Enter the locale to generate (e.g., en_US.UTF-8): " locale

# Validate the locale format
if [[ ! $locale =~ ^[a-z]{2}_[A-Z]{2}\.(UTF-8|utf8)$ ]]; then
    echo "Invalid locale format. Please try again."
    exit 1
fi

# Generate and set the locale
generate_locale "$locale"


# Prompt the user to enter the desired timezone
read -p "Enter the timezone (e.g., Asia/Karachi): " timezone

# Set the clock
set_clock "$timezone"

# Prompt the user to enter the hostname
read -p "Enter the hostname: " hostname

# Define the values to be added to the hosts file
new_entries=(
    "127.0.0.1    localhost"
    "::1          localhost"
    "127.0.1.1    $hostname.localdomain    localhost"
)

# Backup the original hosts file
cp /etc/hosts /etc/hosts.bak

# Clear the hosts file
echo -n > /etc/hosts

# Backup the original hostname file
cp /etc/hostname /etc/hostname.bak

# Update the hostname file
echo "$hostname" > /etc/hostname

# Add the new entries to the hosts file
for entry in "${new_entries[@]}"; do
    echo "$entry" >> /etc/hosts
done

echo "Hostname has been changed to $hostname and new entries have been added to the hosts file."

exit 0

