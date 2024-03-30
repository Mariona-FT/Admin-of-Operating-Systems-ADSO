#!/bin/bash

#rep usuari per parametre
if [ $# -ne 1 ];then
	echo "ús: $0 <nom_d_usuari>"
	exit 1
fi

username="$1" #guardar nom usuari donat
#direccio del seu HOME
dir_usr=$(eval echo ~"$username")

if [ ! -d "$dir_usr" ];then
	echo "Usuari $username no existeix o no te una carpeta home"
	exit 1
fi

#mida del seu direcctori HOME
home_size=$(du -sh "$dir_usr"| cut -f1)

#ALtres directoris fora directori home- usuari fitxers
other_dis=$(find / -type d -user "$username" ! -path "$dir_usr" 2>/dev/null)

#contar num processos actius user
active_proc=$(ps -U "$username" | wc -l)

echo "Home:$dir_usr"
echo "Home size: $home_size"
echo "Other dirs: $altre_dir"
echo "Active processes: $active_proc"
