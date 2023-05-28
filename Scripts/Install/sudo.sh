#!/bin/bash

# Check if the script is being run as root
if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root."
    exit 1
fi

# Check if the line is already uncommented in sudoers
if grep -q "^%wheel ALL=(ALL:ALL) ALL" /etc/sudoers; then
    echo "The line is already uncommented in the sudoers file."
    exit 0
fi

# Uncomment the line in sudoers
sudo sed -i 's/^# %wheel ALL=(ALL:ALL) ALL$/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers

echo "The line has been successfully uncommented in the sudoers file."

exit 0
