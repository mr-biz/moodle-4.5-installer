#!/bin/bash

# Ensure the script is run as root
if [ "$(id -u)" -ne 0 ]; then
  echo "Please run as root"
  exit 1
fi

#  Set Environment Parameters
#
# Set Moodle instance parameters ###########
#
#    Parameters below must be changed
#    |
#    |
#   \ /
#    Y
############################################
#
MOODLE_IP_ADDRESS="192.168.1.60"  # Replace with your actual IP address
MOODLE_URL="moodle.mr-biz.uk"   # Replace with your actual domain name
MOODLE_PROTOCOL="http"       # http or https
CHALLENGE_TYPE="0"  # "0" for no SSL. "1" for HTTP challenge. "2" for DNS challenge
CERTBOT_EMAIL="biz@theitguy.uk"  # Replace with your actual email
#
#######################################################
#
#  Parameters below optionally may be changed
#
#######################################################
#
LOCALE="en_US.UTF-8"
LC_ALL="en_US.UTF-8"
#
# Set environment variables for credentials
MOODLE_DB_NAME="moodle"
MOODLE_DB_USER="moodledude"
MOODLE_DB_PASSWORD=$(openssl rand -base64 32)
REDIS_PASSWORD=$(openssl rand -base64 32)
#
# Set file paths
APACHE_CONF_PATH="/etc/apache2/apache2.conf"
APACHE_PORTS_CONF="/etc/apache2/ports.conf"
MOODLE_VHOST_CONF="/etc/apache2/sites-available/moodle.conf"
MOODLE_INSTALL_DIR="/var/www/html/moodle"
MOODLE_DATA_DIR="/var/moodledata"
APACHE_LOG_DIR="/var/log/apache2"
MOODLE_CONFIG_PHP="$MOODLE_INSTALL_DIR/config.php"

# SSL Certificate Paths (assuming Certbot is used)
SSL_CERT_PATH="/etc/letsencrypt/live/$MOODLE_URL/fullchain.pem"
SSL_KEY_PATH="/etc/letsencrypt/live/$MOODLE_URL/privkey.pem"

# Save parameters to a file for other scripts to use
cat > /tmp/moodle_params.sh <<EOL
MOODLE_DB_NAME="$MOODLE_DB_NAME"
MOODLE_DB_USER="$MOODLE_DB_USER"
MOODLE_DB_PASSWORD="$MOODLE_DB_PASSWORD"
REDIS_PASSWORD="$REDIS_PASSWORD"
MOODLE_IP_ADDRESS="$MOODLE_IP_ADDRESS"
MOODLE_URL="$MOODLE_URL"
MOODLE_PROTOCOL="$MOODLE_PROTOCOL"
CHALLENGE_TYPE="$CHALLENGE_TYPE"
CERTBOT_EMAIL="$CERTBOT_EMAIL"
SSL_CERT_PATH="$SSL_CERT_PATH"
SSL_KEY_PATH="$SSL_KEY_PATH"
LOCALE="$LOCALE"
LC_ALL="$LC_ALL"
APACHE_CONF_PATH="$APACHE_CONF_PATH"
APACHE_PORTS_CONF="$APACHE_PORTS_CONF"
MOODLE_VHOST_CONF="$MOODLE_VHOST_CONF"
MOODLE_INSTALL_DIR="$MOODLE_INSTALL_DIR"
MOODLE_DATA_DIR="$MOODLE_DATA_DIR"
APACHE_LOG_DIR="$APACHE_LOG_DIR"
MOODLE_CONFIG_PHP="$MOODLE_CONFIG_PHP"
EOL

echo "Parameters prepared and saved to /tmp/moodle_params.sh"
