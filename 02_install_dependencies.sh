#!/bin/bash

# Source the parameters
source /tmp/moodle_params.sh

# Update system packages
apt update && apt upgrade -y

# Add PHP repository
apt install software-properties-common -y
add-apt-repository ppa:ondrej/php -y
apt update

# Install necessary packages including Redis and Certbot
apt install -y apache2 postgresql php8.2 libapache2-mod-php8.2 php8.2-pgsql \
php8.2-xml php8.2-curl php8.2-gd php8.2-intl php8.2-ldap \
php8.2-mbstring php8.2-soap php8.2-zip git redis-server php8.2-redis \
certbot python3-certbot-apache

echo "Dependencies installed successfully"
