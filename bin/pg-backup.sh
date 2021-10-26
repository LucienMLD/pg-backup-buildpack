#!/bin/bash

NOW="$(date +"%Y-%m-%d-%s")"
FILENAME="$APP.$NOW.backup.gz"
pg_dump -Fc "$DATABASE_URL" | gzip > "$FILENAME"
echo "$FILENAME"
echo "$DATABASE_URL"
if [ $PG_BACKUP_ENABLE_PGP ] ; then
    if [ -z "${PG_BACKUP_PGP_PUBLIC_KEY}" ]
    then
        echo "Do no upload backup : PG_BACKUP_PGP_PUBLIC_KEY is empty."
        exit 0
    fi

    echo "${PG_BACKUP_PGP_PUBLIC_KEY}" | gpg --no-tty --import
    set -x
    gpg --batch --trust-model always --output "${FILENAME}.gpg" --recipient 'backup@example.com' --encrypt ${FILENAME}
fi

cat << EOF > /app/.s3cfg
[default]

# Object Storage

host_base = $PG_BACKUP_S3_HOST_BASE
host_bucket = $PG_BACKUP_S3_HOST_BUCKET
bucket_location = $PG_BACKUP_S3_BUCKET_LOCATION
use_https = True

# Login credentials

access_key = $PG_BACKUP_S3_KEY_ID
secret_key = $PG_BACKUP_S3_KEY_SECRET
EOF

# echo "$S3CMD_S3CFG" > ~/.s3cfg
export PYTHONPATH= # set the path of python package

if [ $PG_BACKUP_ENABLE_PGP ] ; then
    s3cmd -v put "${FILENAME}.gpg" s3://${PG_BACKUP_S3_BUCKET_NAME}
    rm ${FILENAME} "${FILENAME}.gpg"
else
    s3cmd -v put "${FILENAME}." s3://${PG_BACKUP_S3_BUCKET_NAME}
    rm ${FILENAME}
    rm ${FILENAME} "${FILENAME}.gpg"
fi