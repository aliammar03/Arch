#!/bin/bash

# Function to install packages from a file
install_packages() {
  file="$1"
  pacman -S --noconfirm - < "paclists/$file"
}

# Function to display the menu
display_menu() {
  echo "Please choose a package list to install:"
  echo "1. Essential"
  echo "2. Drivers"
  echo "3. Media"
  echo "4. Fonts"
  echo "5. Print"
  echo "6. Apps"
  echo "0. Exit"
  echo
  read -rp "Enter your choice: " choice
  echo

  case $choice in
    1) install_packages essential.txt ;;
    2) install_packages drivers.txt ;;
    3) install_packages media.txt ;;
    4) install_packages fonts.txt ;;
    5) install_packages print.txt ;;
    6) ./apps.sh ;;  # Launch apps.sh script
    0) echo "Exiting..." ;;
    *) echo "Invalid choice. Please try again." ;;
  esac
}

# Display the menu and process the choice until the user chooses to exit
while true; do
  display_menu
  if [[ $choice -eq 0 ]]; then
    break
  fi
done
