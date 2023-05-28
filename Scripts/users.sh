#!/bin/bash

# Check if the script is being run as root
if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root."
    exit 1
fi

# Function to change the password for a user
change_password() {
    local username=$1

    # Prompt the user to enter the new password
    read -s -p "Enter the new password for $username: " new_password
    echo

    # Prompt the user to confirm the new password
    read -s -p "Confirm the new password for $username: " confirm_password
    echo

    # Check if the passwords match
    if [[ "$new_password" != "$confirm_password" ]]; then
        echo "Passwords do not match for $username. Skipping user."
        return 1
    fi

    # Set the new password for the user
    echo "$username:$new_password" | chpasswd

    echo "Password for $username has been changed successfully."
    return 0
}

# Function to add a user
add_user() {
    local username=$1
    local add_to_wheel=$2

    # Prompt the user to enter the password for the new user
    while true; do
        read -s -p "Enter the password for $username: " user_password
        echo
        read -s -p "Confirm the password for $username: " confirm_password
        echo

        # Check if the passwords match
        if [[ "$user_password" == "$confirm_password" ]]; then
            break
        else
            echo "Passwords do not match. Please try again."
        fi
    done

    # Add the user
    useradd -m -G wheel "$username"

    # Set the password for the new user
    echo "$username:$user_password" | chpasswd

    # Check if the user should be added to the wheel group
    if [[ $add_to_wheel == "yes" ]]; then
        usermod -aG wheel "$username"
        echo "Added $username to the wheel group."
    fi

    echo "User $username has been added successfully."
}

# Change password for the root user
echo "Changing password for root user..."
change_password "root"

# Add additional users
while true; do
    read -p "Do you want to add an additional user? (yes/no): " choice

    case $choice in
        yes)
            read -p "Enter the username for the new user: " username
            read -p "Do you want to add $username to the wheel group? (yes/no): " add_to_wheel

            add_user "$username" "$add_to_wheel"
            ;;
        no)
            break
            ;;
        *)
            echo "Invalid choice. Please try again."
            ;;
    esac
done

exit 0

