#!/bin/bash

# Install git if not already installed
command -v git >/dev/null 2>&1 || { echo >&2 "Git not found. Installing Git..."; \
pacman -Sy --noconfirm git; }

# Clone the Paru repository
git clone https://aur.archlinux.org/paru.git

# Build and install Paru
cd paru
makepkg -si --noconfirm

# Clean up
cd ..
rm -rf paru

# SkipReview
sed -i "31i SkipReview" /etc/paru.conf

echo "Paru has been installed successfully!"
