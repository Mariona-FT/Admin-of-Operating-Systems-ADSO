#!/bin/bash
p=0
usage="Usage: BadUser.sh [-p]"

# Detección de opciones de entrada: solo son válidas: sin parámetros y -p
if [ $# -ne 0 ]; then
    if [ $# -eq 1 ]; then
        if [ $1 == "-p" ]; then 
            p=1
        else
            echo $usage; exit 1
        fi
    else 
        echo $usage; exit 1
    fi
fi

# Agrega una comanda para leer el archivo de contraseñas y obtener solo el campo de nombre de usuario
for user in $(cut -d: -f1 /etc/passwd); do
    home=$(grep "^$user\>" /etc/passwd | cut -d: -f6)
    if [ -d $home ]; then
        num_fich=$(find $home -type f -user $user 2>/dev/null | wc -l)
    else
        num_fich=0
    fi

    if [ $num_fich -eq 0 ]; then
        if [ $p -eq 1 ]; then
            # Agrega una comanda para detectar si el usuario tiene procesos en ejecución,
            # si no tiene ninguno, la variable $user_proc debe ser 0
            user_proc=$(ps -U $user | wc -l)
            if [ $user_proc -eq 1 ]; then
                echo "$user"
            fi
        else
            echo "$user"
        fi
    fi    
done
