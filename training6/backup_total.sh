#!/bin/bash

# Definir las variables
BACKUP_DIR="/home/SergiS/SergiS_total_backups/"
INC_DIR="/home/SergiS/SergiS_incremental_backups"
SOURCE_DIR="/home/SergiS"
DATE=$(date +%Y%m%d%H%M)
BACKUP_FILE="$BACKUP_DIR/total_backup_$DATE.tar.gz"

tar cvf $BACKUP_FILE --exclude="$BACKUP_DIR" --exclude="INC_DIR" $SOURCE_DIR

# Verificar el tamaño total de los backups
TOTAL_SIZE=$(du -s $BACKUP_DIR | cut -f1)

# Si el tamaño es mayor a 100 MB, eliminar los archivos más antiguos
while [ $TOTAL_SIZE -gt 102400 ]; do
    OLDEST_FILE=$(ls -t $BACKUP_DIR | tail -1)
    rm -f $BACKUP_DIR/$OLDEST_FILE
    TOTAL_SIZE=$(du -s $BACKUP_DIR | cut -f1)
done
