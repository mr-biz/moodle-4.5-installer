#!/bin/bash

# Source the parameters
source /tmp/moodle_params.sh

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
  'dbport' => '5432',
  'dbsocket' => '/var/run/postgresql/.s.PGSQL.5432'
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

# Set correct permissions for config.php
chown www-data:www-data $MOODLE_CONFIG_PHP
chmod 0644 $MOODLE_CONFIG_PHP

echo "Moodle configuration completed successfully."
