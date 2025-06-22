#!/bin/bash

# This script restores a SQL Server database from a .bak file in a Docker container, tested with SQL Server 2019 and 2022 Developer Edition on Ubuntu 22.04.

CONTAINER_NAME="mssql_dev"
SA_PASSWORD="my_password"
DATABASE_NAME="my_database"
BAK_FILE_PATH="/mnt/development/my_bak_file.bak"
BAK_FILE_NAME="backup.bak"
DATA_FILE_NAME="${DATABASE_NAME}.mdf"
LOG_FILE_NAME="${DATABASE_NAME}_log.ldf"

echo '=== Copy the .bak file into the container ==='
docker cp "$BAK_FILE_PATH" "$CONTAINER_NAME":/var/opt/mssql/backup/"$BAK_FILE_NAME"

echo '=== Get logical file names from the backup ==='
docker exec -i "$CONTAINER_NAME" /opt/mssql-tools18/bin/sqlcmd \
  -S "localhost,1433" -U SA -P "$SA_PASSWORD" -C \
  -Q "RESTORE FILELISTONLY FROM DISK = '/var/opt/mssql/backup/$BAK_FILE_NAME'" > filelist.txt

DATA_LOGICAL_NAME=$(awk '/_Data/ {print $1; exit}' filelist.txt)
LOG_LOGICAL_NAME=$(awk '/_Log/ {print $1; exit}' filelist.txt)

echo "Data: $DATA_LOGICAL_NAME"
echo "Log:  $LOG_LOGICAL_NAME"

echo '=== Restore the database ==='
docker exec -i "$CONTAINER_NAME" /opt/mssql-tools18/bin/sqlcmd \
  -S "localhost,1433" -U SA -P "$SA_PASSWORD" -C \
  -Q "RESTORE DATABASE [$DATABASE_NAME]
      FROM DISK = '/var/opt/mssql/backup/$BAK_FILE_NAME'
      WITH MOVE '$DATA_LOGICAL_NAME' TO '/var/opt/mssql/data/$DATA_FILE_NAME',
           MOVE '$LOG_LOGICAL_NAME' TO '/var/opt/mssql/data/$LOG_FILE_NAME',
           REPLACE;"

echo "✅ Database '$DATABASE_NAME' restored from '$BAK_FILE_NAME'"