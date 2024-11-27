#!/bin/bash

# Source the parameters
source /tmp/moodle_params.sh

# Set correct permissions for Moodle files and directories:

# For Moodle application files
find $MOODLE_INSTALL_DIR -type d -exec chmod 2770 {} \;
find $MOODLE_INSTALL_DIR -type f -exec chmod 0660 {} \;
chown -R www-data:www-data $MOODLE_INSTALL_DIR

# For Moodle data directory
find $MOODLE_DATA_DIR -type d -exec chmod 2770 {} \;
find $MOODLE_DATA_DIR -type f -exec chmod 0660 {} \;
chown -R www-data:www-data $MOODLE_DATA_DIR

echo "Starting final setup for Moodle..."

# Validate Redis connectivity
if ! nc -z 127.0.0.1 6379; then
    echo "Error: Redis is not running on the expected port (6379)."
    exit 1
fi

# Set up cron job for Moodle tasks
echo "*/1 * * * * /usr/bin/php $MOODLE_INSTALL_DIR/admin/cli/cron.php >/dev/null 2>&1" | crontab -u www-data - || { echo "Error: Failed to set up cron job"; exit 1; }

# Purge Moodle caches
php "$MOODLE_INSTALL_DIR/admin/cli/purge_caches.php" || { echo "Error: Failed to purge Moodle caches"; exit 1; }

# Disable maintenance mode (in case it was enabled during installation)
php "$MOODLE_INSTALL_DIR/admin/cli/maintenance.php" --disable || { echo "Error: Failed to disable maintenance mode"; exit 1; }

# Verify Apache is running
if ! systemctl is-active --quiet apache2; then
    echo "Error: Apache is not running. Attempting to start..."
    systemctl start apache2 || { echo "Failed to start Apache. Please check the logs."; exit 1; }
fi

# Verify PostgreSQL is running
if ! systemctl is-active --quiet postgresql; then
    echo "Error: PostgreSQL is not running. Attempting to start..."
    systemctl start postgresql || { echo "Failed to start PostgreSQL. Please check the logs."; exit 1; }
fi

PGPASSWORD=$MOODLE_DB_PASSWORD psql -h localhost -U $MOODLE_DB_USER -d $MOODLE_DB_NAME -c '\l'


# Display Moodle URL
echo "Moodle installation completed successfully."
echo "You can access your Moodle instance at: $MOODLE_PROTOCOL://$MOODLE_URL"

# Reminder for manual steps
echo "Remember to complete the following manual steps:"
echo "1. Access the Moodle URL in your web browser to complete the web-based setup."
echo "2. Set up an admin account during the web-based setup process."
echo "3. Configure your site settings after logging in as admin."

echo "Moodle setup finalized successfully."
