#!/bin/bash

services=(
  sshd
  networkmanager
  reflector
  gdm
  
)  # List of services to enable

for service in "${services[@]}"; do
  systemctl enable "$service"  # Enable the service
  systemctl start "$service"   # Start the service
done

echo "Services enabled successfully!"
