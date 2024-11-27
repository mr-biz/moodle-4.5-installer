#!/bin/bash

# Check if running as root
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root. Please use sudo or run as root."
    exit 1
fi

apt install git

# Update package lists
apt-get update

# Install locales package if not already installed
apt-get install -y locales

# Generate the en_US.UTF-8 locale
locale-gen en_US.UTF-8

# Set the system-wide locale
echo "LANG=en_US.UTF-8" > /etc/default/locale
echo "LC_ALL=en_US.UTF-8" >> /etc/default/locale

# Update locale configuration
update-locale LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8

# Display current locale settings
echo "Current locale settings:"
locale

# Inform user about the reboot
echo "Locale configuration completed. The system will reboot in 10 seconds."
echo "After reboot, please run the Moodle installation script again."

# Schedule a reboot in 10 seconds
(sleep 10 && reboot) &

# Exit the script
exit 0
