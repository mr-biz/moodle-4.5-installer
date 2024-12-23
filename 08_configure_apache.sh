#!/bin/bash

# Source the parameters
source /tmp/moodle_params.sh

# Configure Apache for Moodle site (HTTP)
cat > "$MOODLE_VHOST_CONF" <<EOL
<VirtualHost *:80>
    ServerName $MOODLE_URL
    ServerAlias $MOODLE_IP_ADDRESS
    ServerAdmin webmaster@localhost
    DocumentRoot $MOODLE_INSTALL_DIR
    
    <Directory $MOODLE_INSTALL_DIR>
        Options FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>

    ErrorLog ${APACHE_LOG_DIR}/moodle_error.log
    CustomLog ${APACHE_LOG_DIR}/moodle_access.log combined
</VirtualHost>
EOL

# Enable necessary Apache modules
a2enmod headers || { echo "Error: Failed to enable headers module"; exit 1; }
a2enmod rewrite || { echo "Error: Failed to enable rewrite module"; exit 1; }

# Only proceed with SSL setup if CHALLENGE_TYPE is not 0
if [ "$CHALLENGE_TYPE" -ne 0 ]; then
    # Install Certbot
    apt update && apt install -y certbot python3-certbot-apache

    # Obtain SSL Certificates based on challenge type
    if [ "$CHALLENGE_TYPE" -eq 1 ]; then
        echo "Obtaining SSL certificates using HTTP challenge..."
        certbot --apache -d "$MOODLE_URL" -d "$MOODLE_IP_ADDRESS" --non-interactive --agree-tos --email "$CERTBOT_EMAIL"
    elif [ "$CHALLENGE_TYPE" -eq 2 ]; then
        echo "Obtaining SSL certificates using DNS challenge..."
        certbot certonly --manual --preferred-challenges dns -d "$MOODLE_URL" -d "$MOODLE_IP_ADDRESS" --non-interactive --agree-tos --email "$CERTBOT_EMAIL"
    fi

    # Configure Apache for HTTPS
    cat > /etc/apache2/sites-available/moodle-ssl.conf <<EOL
<VirtualHost *:443>
    ServerName $MOODLE_URL
    ServerAlias $MOODLE_IP_ADDRESS
    ServerAdmin webmaster@localhost
    DocumentRoot $MOODLE_INSTALL_DIR
    
    <Directory $MOODLE_INSTALL_DIR>
        Options FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>

    ErrorLog ${APACHE_LOG_DIR}/moodle_ssl_error.log
    CustomLog ${APACHE_LOG_DIR}/moodle_ssl_access.log combined

    SSLEngine on
    SSLCertificateFile $SSL_CERT_PATH
    SSLCertificateKeyFile $SSL_KEY_PATH
</VirtualHost>
EOL

    # Enable SSL module and site
    a2enmod ssl || { echo "Error: Failed to enable SSL module"; exit 1; }
    a2ensite moodle-ssl.conf || { echo "Error: Failed to enable Moodle SSL site configuration"; exit 1; }
fi

# Enable HTTP site configuration
a2ensite moodle.conf || { echo "Error: Failed to enable Moodle site configuration"; exit 1; }

# Restart Apache to apply changes
systemctl restart apache2 || { echo "Error: Failed to restart Apache"; exit 1; }

# Validate Apache configuration
if ! apache2ctl -t; then
    echo "Error: Apache configuration test failed."
    exit 1
fi

echo "Apache configuration completed successfully."
