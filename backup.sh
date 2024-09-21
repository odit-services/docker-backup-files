#!/usr/bin/env sh

# Exit on error
set -e

# Check if variables are set
required_vars=("STORAGE_ENDPOINT" "STORAGE_BUCKET" "STORAGE_REGION" "ACCESS_KEY_ID" "SECRET_ACCESS_KEY")

for var in "${required_vars[@]}"; do
  if [ -z "${!var}" ]; then
    echo "$var is not set. Exiting."
    exit 1
  fi
done

# Default values for optional variables
if [ -z "${STORAGE_PATH}" ]; then
    STORAGE_PATH="backup"
fi
if [ -z "${STORAGE_SSL}" ]; then
    STORAGE_SSL="true"
fi
if [ -z "${STORAGE_INSECURE_SKIP_VERIFY}" ]; then
    STORAGE_INSECURE_SKIP_VERIFY="false"
fi

# Check if the data directory exists
if [ ! -d "/data" ]; then
    echo "/data does not exist. Exiting."
    exit 1
fi

# Setup the minio client
if [ "${STORAGE_SSL}" = "true" ]; then
    STORAGE_ENDPOINT="https://${STORAGE_ENDPOINT}"
else
    STORAGE_ENDPOINT="http://${STORAGE_ENDPOINT}"
fi

if [ "${STORAGE_INSECURE_SKIP_VERIFY}" = "true" ]; then
    MC_OPTS="--insecure"
fi

mc alias set backup "${STORAGE_ENDPOINT}" "${ACCESS_KEY_ID}" "${SECRET_ACCESS_KEY}" ${MC_OPTS}

# Check if the bucket exists
if ! mc ls "backup/${STORAGE_BUCKET}" > /dev/null; then
    echo "Bucket ${STORAGE_BUCKET} does not exist. Exiting."
    exit 1
fi

# Backup the data
TIMESTAMP=$(date +%Y%m%d%H%M%S)
echo "Creating backup backup-${TIMESTAMP}"
tar -czf "/tmp/backup-${TIMESTAMP}.tar.gz" /data
echo "Uploading backup-${TIMESTAMP}.tar.gz to ${STORAGE_BUCKET}/${STORAGE_PATH}"
mc cp "/tmp/backup-${TIMESTAMP}.tar.gz" "backup/${STORAGE_BUCKET}/${STORAGE_PATH}/backup-${TIMESTAMP}.tar.gz"
rm "/tmp/backup-${TIMESTAMP}.tar.gz"
echo "Backup completed"

# Cleanup old backups
if [ "${STORAGE_RETENTION}" ]; then
    echo "Checking for old backups"
    backups=$(mc ls "backup/${STORAGE_BUCKET}/${STORAGE_PATH}" --json | jq -r '.key | select(contains("backup-"))' | sort )
    count=$(echo "$backups" | wc -l)
    echo "Found $count backups - keeping ${STORAGE_RETENTION}"
    if [ "$count" -gt "${STORAGE_RETENTION}" ]; then
        delete_count=$((count - STORAGE_RETENTION))
        delete_backups=$(echo "$backups" | head -n $delete_count)
        echo "Deleting $delete_count backups"
        echo "$delete_backups" | xargs -I {} mc rm "backup/${STORAGE_BUCKET}/${STORAGE_PATH}/{}"
    fi
fi

# Exit
exit 0