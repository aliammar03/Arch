#!/bin/bash

# Check if the script is being run as root
if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root."
    exit 1
fi

# Check if the wheel group is already allowed to execute sudo
if grep -q "^%wheel ALL=(ALL) NOPASSWD: ALL" /etc/sudoers; then
    echo "The wheel group is already allowed to execute sudo."
    exit 0
fi

# Use visudo to modify the sudoers file
if ! visudo -cf /etc/sudoers.d/wheel-group; then
    echo "There was an error in the sudoers file syntax. Aborting."
    exit 1
fi

# Add the wheel group configuration to the sudoers file
echo "%wheel ALL=(ALL) NOPASSWD: ALL" | sudo EDITOR='tee -a' visudo -f /etc/sudoers.d/wheel-group

echo "The wheel group is now allowed to execute sudo."

exit 0
