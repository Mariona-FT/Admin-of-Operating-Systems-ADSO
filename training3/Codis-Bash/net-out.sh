#!/bin/bash

# Comprovar si s'ha proporcionat un interval
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <interval_in_seconds>"
    exit 1
fi

# Bucle infinit per mostrar les estadístiques cada N segons
while true; do
    # Obtenir les dades de les interfícies de xarxa
    interfaces=$(cat /proc/net/dev | grep ':' | awk '{print $1}' | tr -d ':')

    total=0

    echo "-----------------------"
    # Processar cada interfície
    for interface in $interfaces; do
        # Obtenir els paquets transmesos per la interfície actual
        packets=$(cat /proc/net/dev | grep "$interface" | awk '{print $10}')
        total=$((total + packets))
        echo -e "$interface:\t$packets"
    done

    # Mostrar el total
    echo -e "Total:\t$total"
    echo "-----------------------"

    # Esperar N segons
    sleep "$1"
done
