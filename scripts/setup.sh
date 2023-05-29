#!/bin/bash

# Make all the scripts executable
chmod +x ./*
chmod +x ./apps/*
chmod +x ./config/*

# Script file paths
scripts=(
  "./basics.sh"
  "./users.sh"
  "./bootloader.sh"
  "./services.sh"
)

# Check if all script files exist and are executable
for script in "${scripts[@]}"; do
  if [ ! -x "$script" ] || [ ! -f "$script" ]; then
    echo "Error: $script is not executable or does not exist."
    exit 1
  fi
done

# Function to display menu options
display_menu() {
  echo "Please select an option:"
  echo "1. Launch basics.sh"
  echo "2. Launch users.sh"
  echo "3. Launch bootloader.sh"
  echo "4. Launch services.sh"
  echo "0. Exit"
}

# Function to execute the selected script
execute_script() {
  case $1 in
    1) "${scripts[0]}" ;;
    2) "${scripts[1]}" ;;
    3) "${scripts[2]}" ;;
    4) "${scripts[3]}" ;;
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
done
