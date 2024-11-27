#!/bin/bash

# Source the parameters
source /tmp/moodle_params.sh

echo "Starting final setup for Moodle..."

# Set correct permissions for Moodle files and directories
# For Moodle application files
find $MOODLE_INSTALL_DIR -type d -exec chmod 2770 {} \;
find $MOODLE_INSTALL_DIR -type f -exec chmod 0660 {} \;
chown -R www-data:www-data $MOODLE_INSTALL_DIR

# For Moodle data directory
find $MOODLE_DATA_DIR -type d -exec chmod 2770 {} \;
find $MOODLE_DATA_DIR -type f -exec chmod 0660 {} \;
chown -R www-data:www-data $MOODLE_DATA_DIR

# Verify database connection with explicit port and socket
echo "Verifying database connection..."

if ! PGPASSWORD=$MOODLE_DB_PASSWORD psql -h localhost -p 5432 -U $MOODLE_DB_USER -d $MOODLE_DB_NAME -c '\l'; then
    echo "Error: Unable to connect to PostgreSQL database."
    exit 1
fi

# Validate Redis connectivity
if ! nc -z 127.0.0.1 6379; then
    echo "Error: Redis is not running on the expected port (6379)."
    exit 1
fi

# Set up cron job for Moodle tasks
echo "*/1 * * * * /usr/bin/php $MOODLE_INSTALL_DIR/admin/cli/cron.php >/dev/null 2>&1" | crontab -u www-data -

# Update config.php with correct database settings if not already set
sed -i "s/'dbport' => ''/'dbport' => '5432'/" "$MOODLE_CONFIG_PHP"
sed -i "s/'dbsocket' => ''/'dbsocket' => '\/var\/run\/postgresql\/.s.PGSQL.5432'/" "$MOODLE_CONFIG_PHP"

# Purge Moodle caches
sudo -u www-data php "$MOODLE_INSTALL_DIR/admin/cli/purge_caches.php" || { 
    echo "Error: Failed to purge Moodle caches"; 
    exit 1; 
}

# Disable maintenance mode
sudo -u www-data php "$MOODLE_INSTALL_DIR/admin/cli/maintenance.php" --disable || { 
    echo "Error: Failed to disable maintenance mode"; 
    exit 1; 
}

# Verify services are running
for service in apache2 postgresql redis-server; do
    if ! systemctl is-active --quiet $service; then
        echo "Error: $service is not running. Attempting to start..."
        systemctl start $service || { 
            echo "Failed to start $service. Please check the logs."; 
            exit 1; 
        }
    fi
done

echo "Moodle installation completed successfully."
echo "You can access your Moodle instance at: $MOODLE_PROTOCOL://$MOODLE_URL"

# Reminder for manual steps
echo "Remember to complete the following manual steps:"
echo "1. Access the Moodle URL in your web browser to complete the web-based setup."
echo "2. Set up an admin account during the web-based setup process."
echo "3. Configure your site settings after logging in as admin."

echo "Moodle setup finalized successfully."
