#!/bin/bash

source /tmp/moodle_params.sh

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

# Test PostgreSQL connection
if su - postgres -c "psql -c '\q'" >/dev/null 2>&1; then
    echo "Successfully connected to PostgreSQL"
else
    echo "Failed to connect to PostgreSQL. Please check the configuration."
    exit 1
fi

# Set up PostgreSQL with UTF-8 encoding
su - postgres << EOF
psql -c "CREATE DATABASE $MOODLE_DB_NAME WITH ENCODING 'UTF8' LC_COLLATE='en_US.UTF-8' LC_CTYPE='en_US.UTF-8' TEMPLATE template0;"
psql -c "CREATE USER $MOODLE_DB_USER WITH ENCRYPTED PASSWORD '$MOODLE_DB_PASSWORD';"
psql -c "GRANT ALL PRIVILEGES ON DATABASE $MOODLE_DB_NAME TO $MOODLE_DB_USER;"
EOF

# Validate PostgreSQL setup
if ! PGPASSWORD=$MOODLE_DB_PASSWORD psql -h localhost -U $MOODLE_DB_USER -d $MOODLE_DB_NAME -c '\q' 2>/dev/null; then
    echo "Error: Unable to connect to PostgreSQL database."
    exit 1
fi

echo "PostgreSQL setup completed successfully."
