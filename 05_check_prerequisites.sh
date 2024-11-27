#!/bin/bash

source /tmp/moodle_params.sh

# Validate essential parameters
if [ -z "$MOODLE_DB_NAME" ] || [ -z "$MOODLE_DB_USER" ] || [ -z "$MOODLE_DB_PASSWORD" ] || [ -z "$REDIS_PASSWORD" ]; then
    echo "Error: Essential parameters are missing."
    exit 1
fi

# Validate parameter format (basic checks)
if [[ ! "$MOODLE_DB_NAME" =~ ^[a-zA-Z0-9_]+$ ]]; then
    echo "Error: Invalid database name format."
    exit 1
fi

if [[ ! "$MOODLE_DB_USER" =~ ^[a-zA-Z0-9_]+$ ]]; then
    echo "Error: Invalid database user format."
    exit 1
fi

if [ ${#MOODLE_DB_PASSWORD} -lt 8 ]; then
    echo "Error: Database password must be at least 8 characters long."
    exit 1
fi

if [ ${#REDIS_PASSWORD} -lt 8 ]; then
    echo "Error: Redis password must be at least 8 characters long."
    exit 1
fi

# Validate IP address format if provided
if [ ! -z "$MOODLE_IP_ADDRESS" ] && ! [[ $MOODLE_IP_ADDRESS =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo "Error: Invalid IP address format."
    exit 1
fi

# Validate URL format if provided
if [ ! -z "$MOODLE_URL" ] && ! [[ $MOODLE_URL =~ ^[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]; then
    echo "Warning: URL format may not be valid for local installations."
fi

# Validate protocol if provided
if [ ! -z "$MOODLE_PROTOCOL" ] && [[ "$MOODLE_PROTOCOL" != "http" && "$MOODLE_PROTOCOL" != "https" ]]; then
    echo "Error: Invalid protocol. Must be 'http' or 'https'."
    exit 1
fi

# Check for required commands
for cmd in psql git apache2 php redis-cli; do
    if ! command -v $cmd &> /dev/null; then
        echo "Error: $cmd is not installed or not in PATH."
        exit 1
    fi
done

echo "All prerequisites checked successfully."
