# pg-backup-buildpack

This buildpack is use to create an external backup of a postgresql database on S3 compatible object storage

## Config
DATABASE_URL
PG_BACKUP_PGP_PUBLIC_KEY
PG_BACKUP_S3_BUCKET_NAME
PG_BACKUP_S3_KEY_ID
PG_BACKUP_S3_KEY_SECRET
PG_BACKUP_S3_HOST_BASE
PG_BACKUP_S3_HOST_BUCKET
PG_BACKUP_S3_BUCKET_LOCATION

### How to install on a repository
- add this builpack in builpack in .buildpacks : `https://github.com/betagouv/pg-backup-buildpack.git`
- add your language builpack in .buildpacks
- add this command `backup-builpack: bin/backup-cron.sh` in Procfile
    - Later we can use scheduled tasks : https://doc.scalingo.com/platform/app/run-scheduled-tasks
- add envs variable : PG_BACKUP_PGP_PUBLIC_KEY and S3 setup
