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

# Prompt the user to choose the desired locale from a list
echo "Choose the locale to generate:"
echo "1. en_US.UTF-8"
echo "2. en_GB.UTF-8"
echo "3. en_AU.UTF-8"
echo "4. en_CA.UTF-8"
echo "5. en_IN.UTF-8"
read -p "Enter your choice (1-5): " locale_choice

# Set the locale based on the user's choice
case $locale_choice in
    1)
        locale="en_US.UTF-8"
        ;;
    2)
        locale="en_GB.UTF-8"
        ;;
    3)
        locale="en_AU.UTF-8"
        ;;
    4)
        locale="en_CA.UTF-8"
        ;;
    5)
        locale="en_IN.UTF-8"
        ;;
    *)
        echo "Invalid choice. Please try again."
        exit 1
        ;;
esac

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

# Clear the hosts file
echo -n > /etc/hosts

# Update the hostname file
echo "$hostname" > /etc/hostname

# Add the new entries to the hosts file
for entry in "${new_entries[@]}"; do
    echo "$entry" >> /etc/hosts
done

echo "Hostname has been changed to $hostname and new entries have been added to the hosts file."

exit 0
