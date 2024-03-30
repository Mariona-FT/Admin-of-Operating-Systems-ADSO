#!/bin/bash

# Get login summary
login_summary=$(last | awk '{print $1}' | sort | uniq -c | awk '{print "Usuari "$2": temps total de login "$1" min, nombre total de logins: "$1}')

# Get active users summary
active_users_summary=$(ps -e -o user,pcpu | awk '{if(NR>1){arr[$1]+=$2; count[$1]++}} END {for(user in arr){print "Usuari "user": "count[user]" processos -> "arr[user]/count[user]"% CPU"}}')

# Print summaries
echo "Resum de logins:"
echo "$login_summary"
echo -e "\nResum d'usuaris connectats"
echo "$active_users_summary"