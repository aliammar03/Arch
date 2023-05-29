#!/bin/bash

# Check if the script is being run as root
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root."
    exit 1
fi

# Create a temporary file
tmp_file=$(mktemp)

# Uncomment the wheel group line in the sudoers file using visudo
visudo -cf "$tmp_file" && \
sed -i 's/^# %wheel ALL=(ALL) ALL$/%wheel ALL=(ALL) ALL/' "$tmp_file" && \
cp --preserve=mode,ownership "$tmp_file" /etc/sudoers

# Clean up the temporary file
rm -f "$tmp_file"
