#!/bin/bash
#NIVELL 0

# Directori d'origen per fer el backup
SOURCE_DIR="/var/log"

# Directori de destinació per guardar el backup
DEST_DIR="/home/aso/backups"

# Fitxer que conté la llista d'exclusions
EXCLUDES="/tmp/exclude.txt"
echo "*.gz" >$EXCLUDES

# Nom o adreça IP del servidor de backup
BSERVER="127.0.0.1"

# Comanda per generar la data actual amb format d'any, mes, dia, hora, minut i segon
BACKUP_DATE=$(date +"%Y-%m-%d_%H-%M-%S")

BASE_NAME="backup-log-nivell0"
BK_NAME="${BASE_NAME}-${BACKUP_DATE}"

# Opcions per a rsync
OPTS="-av --exclude-from=$EXCLUDES --exclude=$BASE_NAME --exclude=$BK_NAME --chmod=u=rwx,g=,o="

# Transferència actual amb rsync
rsync $OPTS $SOURCE_DIR root@$BSERVER:$DEST_DIR
