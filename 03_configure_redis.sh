#!/bin/bash

# Source the parameters
source /tmp/moodle_params.sh

# Escape special characters in the password
ESCAPED_PASSWORD=$(printf '%s\n' "$REDIS_PASSWORD" | sed -e 's/[\/&]/\\&/g')

# Configure Redis
sed -i "s/^requirepass .*/requirepass $ESCAPED_PASSWORD/" /etc/redis/redis.conf

# Restart Redis service
systemctl restart redis-server

# Check if Redis is running
if systemctl is-active --quiet redis-server; then
    echo "Redis configured and started successfully"
else
    echo "Failed to start Redis. Check the logs for more information."
    exit 1
fi
