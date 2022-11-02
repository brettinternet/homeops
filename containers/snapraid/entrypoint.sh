#!/bin/ash

# remove default configuration
if [ ! -L /etc/snapraid.conf ] && [ -f /etc/snapraid.conf ]; then
    rm /etc/snapraid.conf
fi

# Verify user config present
if [ ! -f /config/snapraid.conf ]; then
    echo "No config found. You must configure SnapRAID before running this container."
    exit 1
fi

# Verify user runner config present
if [ ! -f /config/snapraid-runner.conf ]; then
    echo "No config found. You must configure snapraid-runner before running this container"
    exit 1
fi

# Link user config to expected snapraid config location
if [ ! -L /etc/snapraid.conf ]; then
    ln -s /config/snapraid.conf /etc/snapraid.conf
fi

/usr/bin/python3 /app/snapraid-runner/snapraid-runner.py -c /config/snapraid-runner.conf
