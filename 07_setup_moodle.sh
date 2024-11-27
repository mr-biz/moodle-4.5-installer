#!/bin/bash

source /tmp/moodle_params.sh

echo "Starting Moodle setup..."

# Download and set up Moodle
mkdir -p /opt/moodle
cd /opt/moodle || { echo "Error: Unable to change directory to /opt/moodle"; exit 1; }
git clone git://git.moodle.org/moodle.git . || { echo "Error: Git clone failed"; exit 1; }
git branch --track MOODLE_405_STABLE origin/MOODLE_405_STABLE || { echo "Error: Unable to create branch"; exit 1; }
git checkout MOODLE_405_STABLE || { echo "Error: Unable to checkout branch"; exit 1; }

# Validate Moodle download
if [ ! -f "/opt/moodle/version.php" ]; then
    echo "Error: Moodle download seems to have failed."
    exit 1
fi

# Copy Moodle to web directory
mkdir -p "$MOODLE_INSTALL_DIR" || { echo "Error: Unable to create $MOODLE_INSTALL_DIR"; exit 1; }
cp -R /opt/moodle/* "$MOODLE_INSTALL_DIR/" || { echo "Error: Unable to copy Moodle files"; exit 1; }

# Set up moodledata directory
mkdir -p "$MOODLE_DATA_DIR" || { echo "Error: Unable to create $MOODLE_DATA_DIR"; exit 1; }

# Set correct permissions for Moodle installation directory
find "$MOODLE_INSTALL_DIR" -type d -exec chmod 2770 {} \; || { echo "Error: Unable to set directory permissions"; exit 1; }
find "$MOODLE_INSTALL_DIR" -type f -exec chmod 0660 {} \; || { echo "Error: Unable to set file permissions"; exit 1; }
chown -R www-data:www-data "$MOODLE_INSTALL_DIR" || { echo "Error: Unable to set ownership"; exit 1; }

# Set correct permissions for moodledata directory
find "$MOODLE_DATA_DIR" -type d -exec chmod 2770 {} \; || { echo "Error: Unable to set moodledata directory permissions"; exit 1; }
find "$MOODLE_DATA_DIR" -type f -exec chmod 0660 {} \; || { echo "Error: Unable to set moodledata file permissions"; exit 1; }
chown -R www-data:www-data "$MOODLE_DATA_DIR" || { echo "Error: Unable to set moodledata ownership"; exit 1; }

# Validate directory permissions
if [ ! -d "$MOODLE_DATA_DIR" ] || [ ! -w "$MOODLE_DATA_DIR" ]; then
    echo "Error: Moodle data directory does not exist or is not writable."
    exit 1
fi

echo "Moodle setup completed successfully."
