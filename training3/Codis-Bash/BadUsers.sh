#!/bin/bash

usage="Usage: BadUser.sh [-t <duration>]"

# Verifica que s'hagi introduït un paràmetre.
if [ "$#" -ne 2 ] || [ "$1" != "-t" ]; then
    echo $usage
    exit 1
fi

duration=$2

# Obté la data de modificació màxima basada en el paràmetre introduït.
case ${duration: -1} in
    "d") max_age=$(( ${duration%?} ));;
    "m") max_age=$(( ${duration%?} * 30 ));;
    *) echo "Durada no reconeguda. Utilitzeu 'd' per dies i 'm' per mesos."; exit 1;;
esac

for user in $(cut -d: -f1 /etc/passwd); do
    home=$(getent passwd "$user" | cut -d: -f6)
    has_processes=$(ps -ef | grep "^$user " | wc -l)
    last_login=$(lastlog -u "$user" | tail -1 | awk '{print $1, $2, $3, $4, $5}')
    last_login_seconds=$(date -d "$last_login" +%s 2> /dev/null)
    current_seconds=$(date +%s)
    days_since_last_login=$(((current_seconds - last_login_seconds) / 86400))

    if [ -d "$home" ] && [ "$has_processes" -eq 0 ] && [ "$days_since_last_login" -gt "$max_age" ]; then
        has_recent_files=$(find "$home" -type f -user "$user" -mtime -"$max_age" 2> /dev/null | wc -l)
        if [ "$has_recent_files" -eq 0 ]; then
            echo "$user"
        fi
    fi
done
