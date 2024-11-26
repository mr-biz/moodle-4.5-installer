#!/bin/bash

# Configure Apache for Moodle site
cat > /etc/apache2/sites-available/moodle.conf <<EOL
<VirtualHost *:80>
    ServerName localhost
    DocumentRoot /var/www/html/moodle

    <Directory /var/www/html/moodle>
        Options FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>
</VirtualHost>
EOL

a2ensite moodle.conf
a2enmod rewrite
systemctl restart apache2

# Validate Apache configuration
if ! apache2ctl -t; then
    echo "Error: Apache configuration test failed."
    exit 1
fi

echo "Apache configuration completed successfully."
