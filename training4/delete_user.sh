#!/bin/bash

usage="Usage: delete_user.sh [usuari]"

if [ $# -ne 1 ]; then
	echo $usage
	exit 1
fi

chsh -s /usr/local/lib/no-login/prova $1
echo "This account has been closed due to a security problem. Please contact the system administrator"

if [ ! -d $HOME/backups ]; then
	mkdir $HOME/backups
	echo "Backups directory created"
fi 

dir_home=`cat /etc/passwd | grep "^$1\>" | cut -d: -f6`

if [ -d $dir_home ]; then
	tar -cvzf $HOME/backups/$1.tar.gz $dir_home
	rm -r $dir_home
	echo "A $1 copy has been succesfully saved to $HOME"
else 
	echo "The directory $dir_home does not exist"
fi

find / -user $1 -exec rm -r "{}" \; 2> /dev/null

echo "All $1 files have been eliminated"

userdel $1

