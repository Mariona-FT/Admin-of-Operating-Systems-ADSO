#!/bin/bash

# Funció per mostrar l'ús correcte de l'script
usage() {
    echo "Ús: $0 [-g grup] max_permès"
    echo "max_permès ha de ser un valor seguit de K, M o G (per exemple, 600M)"
    exit 1
}

# Comprova si s'ha proporcionat almenys un argument
if [ "$#" -lt 1 ]; then
    usage
fi

# Processa les opcions de línia de comandes
GROUP=""
while getopts 'g:' OPTION; do
    case "$OPTION" in
        g)
            GROUP="$OPTARG"
            ;;
        ?)
            usage
            ;;
    esac
done

# Elimina les opcions processades de la línia de comandes
shift "$((OPTIND - 1))"

# Comprova si s'ha proporcionat el límit permès
if [ "$#" -ne 1 ]; then
    usage
fi

MAX_PERMIS=$1

# Converteix el límit permès a kilobytes per a la comparació
LIMIT_KB=$(echo $MAX_PERMIS | sed 's/K/*1/;s/M/*1024/;s/G/*1048576/' | bc)

# Funció per comprovar l'espai utilitzat i actualitzar .profile si és necessari
comprova_usuari() {
    local usuari=$1
    local directori=$2
    local espai_usat_kb=$3

    # Decideix l'unitat apropiada per a l'espai utilitzat
    if [ "$espai_usat_kb" -ge 1048576 ]; then
        local espai_usat_gb=$(echo "scale=2; $espai_usat_kb/1048576" | bc)
        echo "$usuari		$espai_usat_gb GB"
    elif [ "$espai_usat_kb" -ge 1024 ]; then
        local espai_usat_mb=$(echo "scale=2; $espai_usat_kb/1024" | bc)
        echo "$usuari		$espai_usat_mb MB"
    else
        echo "$usuari		$espai_usat_kb KB"
    fi

    # Comprova si l'espai utilitzat sobrepassa el límit
    if [ "$espai_usat_kb" -gt "$LIMIT_KB" ]; then
        echo "Has sobrepassat l'espai de disc permès. Si us plau, esborra o comprimeix alguns dels teus fitxers." >> $directori/.profile
    fi
}

# Funció per calcular l'espai total utilitzat per un grup
calcula_espai_grup() {
    local grup=$1
    local total_kb=0
    local membres_grup=$(getent group $grup | cut -d: -f4)

    for usuari in ${membres_grup//,/ }; do
        local directori_usuari=$(getent passwd $usuari | cut -d: -f6)
        if [ -d "$directori_usuari" ]; then
            local espai_usat_kb=$(du -s $directori_usuari | cut -f1)
            total_kb=$((total_kb + espai_usat_kb))
            comprova_usuari $usuari $directori_usuari $espai_usat_kb
        fi
    done

    echo "Total grup $grup: $(echo "scale=2; $total_kb/1024" | bc) MB"
}

# Si s'ha especificat un grup, calcula l'espai per aquest grup
if [ -n "$GROUP" ]; then
    calcula_espai_grup $GROUP
else
    # Bucle a través de cada directori d'usuari a /home
    for directori in /home/*; do
        if [ -d "$directori" ]; then
            # Obté el nom d'usuari del nom del directori
            usuari=$(basename $directori)

            # Calcula l'espai en disc utilitzat pel directori de l'usuari en KB
            espai_usat_kb=$(du -s $directori | cut -f1)

            # Comprova l'espai utilitzat i actualitza .profile si és necessari
            comprova_usuari $usuari $directori $espai_usat_kb
        fi
    done
fi

