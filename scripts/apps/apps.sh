#!/bin/bash

# Function to install packages from a file
install_packages() {
  clear
  echo "Installing packages..."
  sleep 1

  # Read package names from the file
  while IFS= read -r package || [[ -n "$package" ]]; do
    # Install each package using Pacman
    sudo pacman -S --noconfirm "$package"
  done < packages.txt

  echo "Packages installed successfully."
  sleep 1
}

# Function to run paru.sh
run_paru() {
  clear
  echo "Running paru.sh..."
  sleep 1

  # Check if paru.sh exists
  if [[ -f "paru.sh" ]]; then
    # Make paru.sh executable
    chmod +x paru.sh

    # Execute paru.sh
    ./paru.sh
  else
    echo "paru.sh not found!"
    sleep 1
  fi
}

# Function to run nordvpn.sh
run_nordvpn() {
  clear
  echo "Running nordvpn.sh..."
  sleep 1

  # Check if nordvpn.sh exists
  if [[ -f "nordvpn.sh" ]]; then
    # Make nordvpn.sh executable
    chmod +x nordvpn.sh

    # Execute nordvpn.sh
    ./nordvpn.sh
  else
    echo "nordvpn.sh not found!"
    sleep 1
  fi
}

# Main menu
while true; do
  clear
  echo "==== Package Installer ===="
  echo "1. Install The Basics"
  echo "2. Install Paru"
  echo "3. Install NordVPN"
  echo "4. Exit"
  echo "==========================="
  read -r choice

  case $choice in
    1)
      install_packages
      ;;
    2)
      run_paru
      ;;
    3)
      run_nordvpn
      ;;
    4)
      clear
      echo "Exiting..."
      sleep 1
      exit 0
      ;;
    *)
      echo "Invalid option! Please try again."
      sleep 1
      ;;
  esac
done
