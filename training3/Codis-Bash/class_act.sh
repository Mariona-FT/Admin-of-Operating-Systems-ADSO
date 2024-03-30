#!/bin/bash

if [ $# -ne 2 ]; then
    echo "Uso: $0 <n> <Nombre y Apellido del usuario>"
    exit 1
fi

n="$1"
user_name="$2"

user_home=""
user_initials=""

user_info="$(getent passwd $user_name)"
if [ -z "$user_info" ]; then
    echo "El usuario no existe."
    exit 1
else
    user_home="$(echo "$user_info" | cut -d: -f6)"
    user_name="$(echo "$user_info" | cut -d: -f5 | cut -d' ' -f1)"
    user_initials="${user_name:0:1}"
fi

limit_date="$(date -d "-$n days" +%s)"

file_count=0  # Declarada como variable global

find "$user_home" -type f -print0 | while IFS= read -r -d $'\0' file_path; do
    file_stat="$(stat -c%Y,%s "$file_path" 2>/dev/null)"
    if [ -z "$file_stat" ]; then
        continue
    fi

    file_modification_time="$(echo "$file_stat" | cut -d, -f1)"
    file_size="$(echo "$file_stat" | cut -d, -f2)"

    if [ "$file_modification_time" -ge "$limit_date" ]; then
        file_count=$((file_count+1))  # Modificamos la variable global
    fi
done

total_size=0  # Otras variables locales pueden ser declaradas dentro del bucle

total_size_mb="$(bc -l <<< "scale=1; $total_size / (1024 * 1024)")"

echo "${user_name} (${user_initials}) ${file_count} archivos modificados que ocupan ${total_size_mb} MB"

