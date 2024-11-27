#!/bin/bash

# Source the parameters
source /tmp/moodle_params.sh

# Set up PostgreSQL with UTF-8 encoding
sudo -u postgres psql <<EOF
CREATE DATABASE $MOODLE_DB_NAME WITH ENCODING 'UTF8' LC_COLLATE='en_US.UTF-8' LC_CTYPE='en_US.UTF-8' TEMPLATE=template0;
CREATE USER $MOODLE_DB_USER WITH ENCRYPTED PASSWORD '$MOODLE_DB_PASSWORD';
GRANT ALL PRIVILEGES ON DATABASE $MOODLE_DB_NAME TO $MOODLE_DB_USER;
\q
EOF

# Download and set up Moodle
mkdir -p /opt/moodle
cd /opt/moodle
git clone git://git.moodle.org/moodle.git .
git branch --track MOODLE_405_STABLE origin/MOODLE_405_STABLE
git checkout MOODLE_405_STABLE

# Copy Moodle to web directory and set permissions
mkdir -p $MOODLE_INSTALL_DIR
cp -R /opt/moodle/* $MOODLE_INSTALL_DIR/
chown -R root:root $MOODLE_INSTALL_DIR
chmod -R 0755 $MOODLE_INSTALL_DIR

# Set up moodledata directory
mkdir -p $MOODLE_DATA_DIR
chown www-data:www-data $MOODLE_DATA_DIR
chmod 0770 $MOODLE_DATA_DIR

# Configure Apache for Moodle site
cat > $MOODLE_VHOST_CONF <<EOL
<VirtualHost *:80>
    ServerName localhost
    DocumentRoot $MOODLE_INSTALL_DIR

    <Directory $MOODLE_INSTALL_DIR>
        Options FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>
</VirtualHost>
EOL

a2ensite moodle.conf
a2enmod rewrite
systemctl restart apache2

# Create config.php with Redis configuration
cat > $MOODLE_CONFIG_PHP <<EOL
<?php
unset(\$CFG);
global \$CFG;
\$CFG = new stdClass();

\$CFG->dbtype    = 'pgsql';
\$CFG->dblibrary = 'native';
\$CFG->dbhost    = 'localhost';
\$CFG->dbname    = '$MOODLE_DB_NAME';
\$CFG->dbuser    = '$MOODLE_DB_USER';
\$CFG->dbpass    = '$MOODLE_DB_PASSWORD';
\$CFG->prefix    = 'mdl_';
\$CFG->langstringcache = true;
\$CFG->forum_trackreadposts = false;
\$CFG->forum_usermarksread = true;
\$CFG->cachetext = true;
\$CFG->unicodedb = true;
\$CFG->maxbytes = 268435456;

\$CFG->dboptions = array (
  'dbpersist' => 0,
  'dbport' => '',
  'dbsocket' => '',
);

\$CFG->wwwroot = 'http://localhost';
\$CFG->dataroot  = '$MOODLE_DATA_DIR';
\$CFG->admin     = 'admin';
\$CFG->directorypermissions = 0755;

\$CFG->session_handler_class = '\core\session\redis';
\$CFG->session_redis_host = '127.0.0.1';
\$CFG->session_redis_port = 6379;
\$CFG->session_redis_auth = '$REDIS_PASSWORD';
\$CFG->session_redis_prefix = 'moodle_sess_';
\$CFG->session_redis_acquire_lock_timeout = 120;
\$CFG->session_redis_lock_expire = 7200;
define('CONTEXT_CACHE_MAX_SIZE', 7500);

require_once(__DIR__ . '/lib/setup.php');
EOL

# Set correct permissions for config.php
chown root:root $MOODLE_CONFIG_PHP
chmod 0644 $MOODLE_CONFIG_PHP

# Set up cron job for Moodle tasks
echo "*/1 * * * * /usr/bin/php $MOODLE_INSTALL_DIR/admin/cli/cron.php >/dev/null 2>&1" | crontab -u www-data -

echo "Moodle setup completed successfully."
