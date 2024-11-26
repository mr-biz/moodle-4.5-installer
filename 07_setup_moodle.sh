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
mkdir -p /var/www/html/moodle
cp -R /opt/moodle/* /var/www/html/moodle/
chown -R root:root /var/www/html/moodle
chmod -R 0755 /var/www/html/moodle

# Set up moodledata directory
mkdir -p /var/moodledata
chown www-data:www-data /var/moodledata
chmod 0770 /var/moodledata

# Validate moodledata directory
if [ ! -d "/var/moodledata" ] || [ ! -w "/var/moodledata" ]; then
    echo "Error: Moodle data directory does not exist or is not writable."
    exit 1
fi

echo "Moodle setup completed successfully."
