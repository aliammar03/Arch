#!/bin/bash

# Check if the script is being run as root
if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root."
    exit 1
fi

# Set firefox environment variable
echo "MOZ_ENABLE_WAYLAND=1" >> /etc/environment
