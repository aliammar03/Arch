#!/bin/bash

# Install Paru if not already installed
command -v paru >/dev/null 2>&1 || { echo >&2 "Paru not found. Installing Paru..."; \
git clone https://aur.archlinux.org/paru.git && \
cd paru && \
makepkg -si && \
cd .. && \
rm -rf paru; }

# Install NordVPN using Paru
paru -S nordvpn-bin

# Add user to the 'nordvpn' group
sudo usermod -aG nordvpn $(whoami)


# Enable and start NordVPN service
sudo systemctl enable nordvpnd.service
sudo systemctl start nordvpnd.service

# Set NordVPN technology to NordLynx
nordvpn set technology nordlynx

echo "NordVPN has been installed and configured successfully!"
