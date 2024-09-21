export STORAGE_ENDPOINT="play.min.io"
export STORAGE_BUCKET="test-files-backup"
export STORAGE_REGION="test"
export STORAGE_PATH=""
export STORAGE_SSL="true"
export STORAGE_INSECURE_SKIP_VERIFY="false"
export STORAGE_RETENTION="2"
export ACCESS_KEY_ID="Q3AM3UQ867SPQQA43P2F"
export SECRET_ACCESS_KEY="zuf+tfteSlswRu7BJ86wekitnifILbZam1KYY3TG"

mc alias set play https://play.min.io Q3AM3UQ867SPQQA43P2F zuf+tfteSlswRu7BJ86wekitnifILbZam1KYY3TG
mc mb "play/${STORAGE_BUCKET}"

# Run the backup script
bash ./backup.sh

# List the contents of the bucket
mc ls "play/${STORAGE_BUCKET}"