#!/bin/bash

# Ensure the script is run as root
if [ "$(id -u)" -ne 0 ]; then
  echo "Please run as root"
  exit 1
fi

# Set environment variables for credentials
MOODLE_DB_NAME="moodle"
MOODLE_DB_USER="moodledude"
MOODLE_DB_PASSWORD=$(openssl rand -base64 32)
REDIS_PASSWORD=$(openssl rand -base64 32)

# Save parameters to a file for other scripts to use
cat > /tmp/moodle_params.sh <<EOL
MOODLE_DB_NAME="$MOODLE_DB_NAME"
MOODLE_DB_USER="$MOODLE_DB_USER"
MOODLE_DB_PASSWORD="$MOODLE_DB_PASSWORD"
REDIS_PASSWORD="$REDIS_PASSWORD"
EOL

echo "Parameters prepared and saved to /tmp/moodle_params.sh"
