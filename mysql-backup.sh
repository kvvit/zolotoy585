#!/bin/bash

TODAY=`date +"%H%M%d%m%Y"`

DB_BACKUP_PATH='/backup/dbbackup'
MYSQL_HOST='localhost'
MYSQL_PORT='3306'
MYSQL_USER='root'
MYSQL_PASSWORD='Zolotoy585'
DATABASE_NAME='Zolotoy585'
BACKUP_RETAIN_DAYS=1

echo "Backup started for database - ${DATABASE_NAME}"

mysqldump -h ${MYSQL_HOST} \
   -P ${MYSQL_PORT} \
   -u ${MYSQL_USER} \
   -p${MYSQL_PASSWORD} \
   ${DATABASE_NAME} > ${DB_BACKUP_PATH}/${DATABASE_NAME}-${TODAY}.sql

find ${DB_BACKUP_PATH} -name "*.sql" -type f -mtime +1 -exec rm -f {} \;
