#!/bin/bash
#NIVELL 1

# Directori d'origen per fer el backup
SOURCE_DIR="/var/log"

# Directori de destinació per guardar el backup
DEST_DIR="/home/aso/backup"

# Fitxer que conté la llista d'exclusions
EXCLUDES="/tmp/exclude.txt"
echo "*.gz" >$EXCLUDES

# Nom o adreça IP del servidor de backup
BSERVER="10.192.59.147"

# Num PORT
PSERVER="3022"

# Comanda per generar la data actual amb format d'any, mes, dia, hora, minut i segon
BACKUP_DATE=$(date +"%Y-%m-%d_%H-%M-%S")

# Nom base per als fitxers de backup
BASE_NAME="backup-log-nivell1"

# Nivell de backup (0 per complet, 1 per incremental)
BACKUP_LEVEL=1

BK_NAME="${BASE_NAME}${BACKUP_LEVEL}-${BACKUP_DATE}"

# Fitxer de referència per backups incrementals
REF_FILE="${DEST_DIR}/${BASE_NAME}0-latest"

# Comprova si existeix el fitxer de referència per a backups incrementals
if [ ! -f "$REF_FILE" ]; then
	echo "No es troba el fitxer de referència del backup complet. Creant backup complet primer."
	BACKUP_LEVEL=0
	BK_NAME="${BASE_NAME}${BACKUP_LEVEL}-${BACKUP_DATE}"
	REF_FILE="${DEST_DIR}/${BK_NAME}"
fi


mkdir -p $DEST_DIR/
mkdir -p $DEST_DIR/$BK_NAME

# Opcions per a rsync
OPTS="-avz --exclude-from=$EXCLUDES --exclude=$BASE_NAME --exclude=$BK_NAME --chmod=u=rwx,g=,o="

# Transferència actual amb rsync
rsync $OPTS -e "ssh -p 3022" $SOURCE_DIR root@$BSERVER:$DEST_DIR/$BK_NAME

# Actualitza el fitxer de referència si es tracta d'un backup complet

