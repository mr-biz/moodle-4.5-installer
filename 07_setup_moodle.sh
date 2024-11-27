#!/bin/bash

source /tmp/moodle_params.sh

# Download and set up Moodle
mkdir -p /opt/moodle
cd /opt/moodle
git clone git://git.moodle.org/moodle.git .
git branch --track MOODLE_405_STABLE origin/MOODLE_405_STABLE
git checkout MOODLE_405_STABLE

# Validate Moodle download
if [ ! -f "/opt/moodle/version.php" ]; then
    echo "Error: Moodle download seems to have failed."
    exit 1
fi

# Copy Moodle to web directory and set permissions
mkdir -p $MOODLE_INSTALL_DIR
cp -R /opt/moodle/* $MOODLE_INSTALL_DIR/
chown -R root:root $MOODLE_INSTALL_DIR
chmod -R 0755 $MOODLE_INSTALL_DIR

# Set up moodledata directory
mkdir -p $MOODLE_DATA_DIR
chown www-data:www-data $MOODLE_DATA_DIR
chmod 0770 $MOODLE_DATA_DIR

# Validate moodledata directory
if [ ! -d "$MOODLE_DATA_DIR" ] || [ ! -w "$MOODLE_DATA_DIR" ]; then
    echo "Error: Moodle data directory does not exist or is not writable."
    exit 1
fi

echo "Moodle setup completed successfully."
