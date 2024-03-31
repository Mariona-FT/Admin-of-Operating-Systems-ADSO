#!/bin/bash
#NIVELL 2

# Directori d'origen per fer el backup
SOURCE_DIR="/var/log"

# Directori de destinació per guardar el backup
DEST_DIR="/home/aso/backups"

# Fitxer que conté la llista d'exclusions
EXCLUDES="/tmp/exclude.txt"
echo "*.gz" > $EXCLUDES

# Nom o adreça IP del servidor de backup
BSERVER="127.0.0.1"

# Comanda per generar la data actual amb format d'any, mes, dia, hora, minut i segon
BACKUP_DATE=$(date +"%Y-%m-%d_%H-%M-%S")

# Nom base per als fitxers de backup
BASE_NAME="backup-log-nivell2"

# Nivell de backup (0 per complet, 1 per incremental, 2 per incremental diari)
BACKUP_LEVEL=2

# Nom complet del fitxer de backup
BK_NAME="${BASE_NAME}-${BACKUP_DATE}.tar"

# Directori temporal per al backup
TMP_DIR="/tmp/backup-${BACKUP_DATE}"
mkdir -p $TMP_DIR

# Fitxer de referència per backups incrementals de nivell 1
REF_FILE="${DEST_DIR}/backup-log-nivell1-latest"

# Comprova si existeix el fitxer de referència per a backups incrementals de nivell 1
if [ ! -f "$REF_FILE" ]; then
    echo "No es troba el fitxer de referència del backup de nivell 1. Creant backup de nivell 1 primer."
    exit 1
fi

# Crear un arxiu tar del backup
tar -cvpf $TMP_DIR/$BK_NAME --exclude-from=$EXCLUDES --listed-incremental=$REF_FILE $SOURCE_DIR

# Transferència del arxiu tar amb rsync
rsync -av $TMP_DIR/$BK_NAME root@$BSERVER:$DEST_DIR/

# Neteja del directori temporal
rm -rf $TMP_DIR

# Actualitza el fitxer de referència de nivell 2
ln -fns $BK_NAME "${DEST_DIR}/backup-log-nivell2-latest"
