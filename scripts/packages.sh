#!/bin/bash

# Function to install packages from a file
install_packages() {
  file="$1"
  pacman -S --noconfirm - < "./script/paclists/$file"
}

# Function to display the menu
display_menu() {
  echo "Please choose a package list to install:"
  echo "1. Essential"
  echo "2. Drivers"
  echo "3. Media"
  echo "4. Fonts"
  echo "5. Print"
  echo "6. Gnome"
  echo "7. Install from all package lists"
  echo "8. Apps"
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
    6) install_packages gnome.txt ;;
    7) install_all_packages ;;
    8) ./scripts/apps/apps.sh ;;  # Launch apps.sh script
    0) echo "Exiting..." ;;
    *) echo "Invalid choice. Please try again." ;;
  esac
}

# Function to install packages from all package list files
install_all_packages() {
  install_packages essential.txt
  install_packages drivers.txt
  install_packages media.txt
  install_packages fonts.txt
  install_packages print.txt
  install_packages gnome.txt
}

# Display the menu and process the choice until the user chooses to exit
while true; do
  display_menu
  if [[ $choice -eq 0 ]]; then
    break
  fi
done
