#!/bin/bash

# Source the parameters
source /tmp/moodle_params.sh

# Set up PostgreSQL with UTF-8 encoding
-u postgres psql <<EOF
CREATE DATABASE $MOODLE_DB_NAME WITH ENCODING 'UTF8' LC_COLLATE='en_US.UTF-8' LC_CTYPE='en_US.UTF-8' TEMPLATE=template0;
CREATE USER $MOODLE_DB_USER WITH ENCRYPTED PASSWORD '$MOODLE_DB_PASSWORD';
GRANT ALL PRIVILEGES ON DATABASE $MOODLE_DB_NAME TO $MOODLE_DB_USER;
\q
EOF


# Configure Apache for Moodle site
cat > $MOODLE_VHOST_CONF <<EOL
<VirtualHost *:80>
    ServerName $MOODLE_URL
    ServerAlias $MOODLE_IP_ADDRESS
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

\$CFG->wwwroot = '$MOODLE_PROTOCOL://$MOODLE_URL';
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


echo "Moodle setup completed successfully."
