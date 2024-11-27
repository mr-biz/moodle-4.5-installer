#!/bin/bash

for script in {01..10}*.sh; do
    if [ -x "$script" ]; then
        echo "Running $script..."
        ./"$script"
        if [ $? -ne 0 ]; then
            echo "Error: $script failed. Stopping installation."
            exit 1
        fi
    fi
done

echo "Moodle installation completed successfully."
