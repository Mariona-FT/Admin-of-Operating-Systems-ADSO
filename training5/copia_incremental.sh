#!/bin/bash

# Directori d'origen per fer el backup
SOURCE_DIR="/root/"

# Directori de destinació per guardar el backup
DEST_DIR="/backup/backup-rsync"

# Fitxer que conté la llista d'exclusions
EXCLUDES="/root/Documents/llista_excloure.txt"

# Nom o adreça IP del servidor de backup
BSERVER="127.0.0.1"

# Nom del directori on es guardaran els backups incrementals
INCREMENTAL_BACKUP_DIR="incrementals"

# Comanda per generar la data actual amb format d'any, mes, dia, hora, minut i segon
BACKUP_DATE=$(date +"%Y-%m-%d_%H-%M-%S")

# Opcions per a rsync
OPTS="--ignore-errors --delete-excluded --exclude-from=$EXCLUDES \
--delete --backup --backup-dir=$DEST_DIR/$INCREMENTAL_BACKUP_DIR/$BACKUP_DATE -av"

# Assegura que el directori de backup incremental existeix
mkdir -p $DEST_DIR/$INCREMENTAL_BACKUP_DIR/$BACKUP_DATE

# Transferència actual amb rsync
rsync $OPTS $SOURCE_DIR root@$BSERVER:$DEST_DIR/complet
