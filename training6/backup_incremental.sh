#!/bin/bash

# Definir las variables
BACKUP_DIR="/home/SergiS/SergiS_incremental_backups/"
TOT_DIR="/home/SergiS/SergiS_total_backups"
SOURCE_DIR="/home/SergiS"
DATE=$(date +%Y%m%d)
BACKUP_FILE="$BACKUP_DIR/incremental_backup_$DATE.tar.gz"
SNAPSHOT_FILE="$BACKUP_DIR/snapshot.file"

# Crear el archivo de copia de seguridad incremental
tar -cvf $BACKUP_FILE --exclude="$BACKUP_DIR" --exclude="$TOT_DIR" --listed-incremental=$SNAPSHOT_FILE $SOURCE_DIR 
