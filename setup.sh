#!/bin/bash

# Script directory path
script_dir="./scripts"

# Make all the scripts executable
chmod +x ./*
chmod +x ./apps/*
chmod +x $script_dir/*

# Script file paths
basics_script="$script_dir/basics.sh"
users_script="$script_dir/users.sh"
bootloader_script="$script_dir/bootloader.sh"
services_script="$script_dir/services.sh"
apps_script="$script_dir/apps.sh"

# Check if the script directory exists
if [ ! -d "$script_dir" ]; then
  echo "Error: Script directory '$script_dir' does not exist."
  exit 1
fi

# Check if all script files exist and are executable
if [ ! -x "$basics_script" ] || [ ! -f "$basics_script" ]; then
  echo "Error: $basics_script is not executable or does not exist."
  exit 1
fi

if [ ! -x "$users_script" ] || [ ! -f "$users_script" ]; then
  echo "Error: $users_script is not executable or does not exist."
  exit 1
fi

if [ ! -x "$bootloader_script" ] || [ ! -f "$bootloader_script" ]; then
  echo "Error: $bootloader_script is not executable or does not exist."
  exit 1
fi

if [ ! -x "$services_script" ] || [ ! -f "$services_script" ]; then
  echo "Error: $services_script is not executable or does not exist."
  exit 1
fi

if [ ! -x "$apps_script" ] || [ ! -f "$apps_script" ]; then
  echo "Error: $apps_script is not executable or does not exist."
  exit 1
fi

# Function to display menu options
display_menu() {
  echo "Please select an option:"
  echo "1. Launch basics.sh"
  echo "2. Launch users.sh"
  echo "3. Launch bootloader.sh"
  echo "4. Launch services.sh"
  echo "5. Launch apps.sh"
  echo "0. Exit"
}

# Function to execute the selected script
execute_script() {
  case $1 in
    1) "$basics_script";;
    2) "$users_script";;
    3) "$bootloader_script";;
    4) "$services_script";;
    5) "$apps_script";;
    0) echo "Exiting..." && exit ;;
    *) echo "Invalid option. Please try again." ;;
  esac
}

# Main loop
while true; do
  display_menu
  read -p "Enter your choice: " choice
  echo

  execute_script "$choice"

  echo
  read -p "Press Enter to continue..."
  echo
done
