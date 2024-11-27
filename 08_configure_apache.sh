#!/bin/bash

# Source the parameters
source /tmp/moodle_params.sh

# Configure Apache for Moodle site
cat > $MOODLE_VHOST_CONF <<EOL
<VirtualHost *:80>
    ServerName $SERVER_NAME
    ServerAdmin webmaster@localhost
    DocumentRoot $MOODLE_INSTALL_DIR
    
    <Directory $MOODLE_INSTALL_DIR>
        Options FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>

    ErrorLog ${APACHE_LOG_DIR}/error.log
    CustomLog ${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
EOL

a2enmod ssl
a2enmod headers
a2ensite moodle.conf
a2enmod rewrite
systemctl restart apache2

# Validate Apache configuration
if ! apache2ctl -t; then
    echo "Error: Apache configuration test failed."
    exit 1
fi

echo "Apache configuration completed successfully."
