#!/bin/bash

# Source the parameters
source /tmp/moodle_params.sh

# Escape special characters in the password
ESCAPED_PASSWORD=$(printf '%s\n' "$REDIS_PASSWORD" | sed -e 's/[\/&]/\\&/g')

# Configure Redis
if [ -f "/etc/redis/redis.conf" ]; then
    sed -i "s/^# requirepass .*/requirepass $ESCAPED_PASSWORD/" /etc/redis/redis.conf
    sed -i "s/^requirepass .*/requirepass $ESCAPED_PASSWORD/" /etc/redis/redis.conf
else
    echo "Error: Redis configuration file not found."
    exit 1
fi

# Restart Redis service
systemctl restart redis-server

# Check if Redis is running
if systemctl is-active --quiet redis-server; then
    echo "Redis configured and started successfully"
else
    echo "Failed to start Redis. Check the logs for more information."
    exit 1
fi

# Validate Redis connectivity
if ! nc -z 127.0.0.1 6379; then
    echo "Error: Redis is not accessible on port 6379."
    exit 1
fi

echo "Redis configuration completed successfully."
