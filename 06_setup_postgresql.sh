#!/bin/bash

source /tmp/moodle_params.sh

# Ensure required locales are available
echo "Ensuring required locales are available..."
if ! locale -a | grep -q 'en_US.utf8'; then
    echo "en_US.UTF-8 locale not found. Generating..."
    locale-gen en_US.UTF-8 || { echo "Failed to generate en_US.UTF-8 locale"; exit 1; }
    update-locale LANG=en_US.UTF-8 || { echo "Failed to update locales"; exit 1; }
else
    echo "en_US.UTF-8 locale already available."
fi

# Check PostgreSQL status and start if necessary
if systemctl is-active --quiet postgresql; then
    echo "PostgreSQL is running"
else
    echo "PostgreSQL is not running. Attempting to start..."
    systemctl start postgresql
    if systemctl is-active --quiet postgresql; then
        echo "PostgreSQL started successfully"
    else
        echo "Failed to start PostgreSQL. Please check the logs."
        exit 1
    fi
fi

# Configure PostgreSQL authentication method
cat > /etc/postgresql/*/main/pg_hba.conf << EOL
# Database administrative login by Unix domain socket
local   all             postgres                                peer

# TYPE  DATABASE        USER            ADDRESS                 METHOD
local   all             all                                     md5
host    all             all             127.0.0.1/32            md5
host    all             all             ::1/128                 md5
local   replication     all                                     peer
host    replication     all             127.0.0.1/32            scram-sha-256
host    replication     all             ::1/128                 scram-sha-256
EOL

# Restart PostgreSQL to apply authentication changes
systemctl restart postgresql || { echo "Failed to restart PostgreSQL after authentication update"; exit 1; }

# Test PostgreSQL connection
if su - postgres -c "psql -c '\q'" >/dev/null 2>&1; then
    echo "Successfully connected to PostgreSQL"
else
    echo "Failed to connect to PostgreSQL. Please check the configuration."
    exit 1
fi

# Set up PostgreSQL with UTF-8 encoding
echo "Setting up PostgreSQL database..."
su - postgres << EOF
psql -c "DROP DATABASE IF EXISTS $MOODLE_DB_NAME;"
psql -c "DROP USER IF EXISTS $MOODLE_DB_USER;"
psql -c "CREATE DATABASE $MOODLE_DB_NAME WITH ENCODING 'UTF8' LC_COLLATE='en_US.utf8' LC_CTYPE='en_US.utf8' TEMPLATE template0;"
psql -c "CREATE USER $MOODLE_DB_USER WITH ENCRYPTED PASSWORD '$MOODLE_DB_PASSWORD';"
psql -c "GRANT ALL PRIVILEGES ON DATABASE $MOODLE_DB_NAME TO $MOODLE_DB_USER;"
EOF

# Validate PostgreSQL setup
echo "Validating PostgreSQL setup..."
if ! PGPASSWORD=$MOODLE_DB_PASSWORD psql -h localhost -p 5432 -U $MOODLE_DB_USER -d $MOODLE_DB_NAME -c '\l' 2>/dev/null; then
    echo "Error: Unable to connect to PostgreSQL database."
    exit 1
fi

echo "PostgreSQL setup completed successfully."
