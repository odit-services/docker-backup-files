#!/usr/bin/env sh

# Exit on error
set -e

if [ -z "${TIME_SCHEDULE}" ]; then
    echo "$TIME_SCHEDULE is not set. Exiting."
    exit 1
fi

# Generate crontab
echo "${TIME_SCHEDULE} bash /backup.sh" > /tmp/crontab
crontab - < /tmp/crontab

# Start cron
crond -f