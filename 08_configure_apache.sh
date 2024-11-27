#!/bin/bash

# Source the parameters
source /tmp/moodle_params.sh

# Configure Apache for Moodle site
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
a2enmod ssl || { echo "Error: Failed to enable SSL module"; exit 1; }
a2enmod headers || { echo "Error: Failed to enable headers module"; exit 1; }
a2enmod rewrite || { echo "Error: Failed to enable rewrite module"; exit 1; }

# Enable Moodle site configuration
a2ensite moodle.conf || { echo "Error: Failed to enable Moodle site configuration"; exit 1; }

# Restart Apache
systemctl restart apache2 || { echo "Error: Failed to restart Apache"; exit 1; }

# Validate Apache configuration
if ! apache2ctl -t; then
    echo "Error: Apache configuration test failed."
    exit 1
fi

echo "Apache configuration completed successfully."
