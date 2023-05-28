#!/bin/bash

# Get the current directory
current_dir=$(pwd)

# Iterate over all files in the current directory
for file in "$current_dir"/*; do
    # Check if the file is a script (executable permission not set)
    if [[ -f $file && -x $file ]]; then
        # Set the executable permission for the file
        chmod +x "$file"
        echo "Executable permission set for: $file"
    fi
done

echo "All scripts in the current directory are now executable."
