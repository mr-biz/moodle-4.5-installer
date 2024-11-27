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

# Set file paths
APACHE_CONF_PATH="/etc/apache2/apache2.conf"
APACHE_PORTS_CONF="/etc/apache2/ports.conf"
MOODLE_VHOST_CONF="/etc/apache2/sites-available/moodle.conf"
MOODLE_INSTALL_DIR="/var/www/html/moodle"
MOODLE_DATA_DIR="/var/moodledata"
APACHE_LOG_DIR="/var/log/apache2"
MOODLE_CONFIG_PHP="$MOODLE_INSTALL_DIR/config.php"

# Save parameters to a file for other scripts to use
cat > /tmp/moodle_params.sh <<EOL
MOODLE_DB_NAME="$MOODLE_DB_NAME"
MOODLE_DB_USER="$MOODLE_DB_USER"
MOODLE_DB_PASSWORD="$MOODLE_DB_PASSWORD"
REDIS_PASSWORD="$REDIS_PASSWORD"
APACHE_CONF_PATH="$APACHE_CONF_PATH"
APACHE_PORTS_CONF="$APACHE_PORTS_CONF"
MOODLE_VHOST_CONF="$MOODLE_VHOST_CONF"
MOODLE_INSTALL_DIR="$MOODLE_INSTALL_DIR"
MOODLE_DATA_DIR="$MOODLE_DATA_DIR"
APACHE_LOG_DIR="$APACHE_LOG_DIR"
MOODLE_CONFIG_PHP="$MOODLE_CONFIG_PHP"
EOL

echo "Parameters prepared and saved to /tmp/moodle_params.sh"
