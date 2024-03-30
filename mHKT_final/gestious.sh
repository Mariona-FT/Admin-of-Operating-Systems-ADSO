#!/bin/bash

# Check if filename is provided as a parameter
if [ $# -eq 0 ]; then
    echo "No filename provided. Usage: ./scriptname.sh usuaris.txt"
    exit 1
fi

filename=$1

# If /dev/null is passed as a parameter, delete users
if [ "$2" == "/dev/null" ]; then
    while IFS=',' read -r cognom nom equip
    do
        # Remove spaces
        cognom=${cognom// /}
        nom=${nom// /}
        equip=${equip// /}

        # Check if user exists
        if id -u "$cognom" >/dev/null 2>&1; then
            # Delete user
            userdel "$cognom"
            echo "User $cognom deleted."

            # Delete user's directory
            if [ -d "/home/$equip/$cognom" ]; then
                rm -r "/home/$equip/$cognom"
                echo "User directory /home/$equip/$cognom deleted."
            fi

            # Delete team directory if it's empty
            if [ ! "$(ls -A /home/$equip)" ]; then
                rm -r "/home/$equip"
                echo "Team directory /home/$equip deleted."
            fi
        else
            echo "User $cognom does not exist. Skipping."
        fi
    done < "$filename"
else
    declare -A equip_members

    while IFS=',' read -r cognom nom equip
    do
        # Remove spaces
        cognom=${cognom// /}
        nom=${nom// /}
        equip=${equip// /}

        # Check if user already exists
        if id -u "$cognom" >/dev/null 2>&1; then
            echo "User $cognom already exists. Skipping."
        else
            # Create user without a home directory
            useradd "$cognom"
            echo "User $cognom created."

            # Set user password to cognom
            echo "$cognom:$cognom" | chpasswd
            echo "Password for user $cognom set to $cognom."

            # Create team directory if it doesn't exist
            if [ ! -d "/home/$equip" ]; then
                mkdir "/home/$equip"
                mkdir "/home/$equip/grup"
                mkdir "/home/$equip/public"
                echo "Directory /home/$equip created."
            fi

            # Add user to team group
            groupadd -f "$equip"
            usermod -a -G "$equip" "$cognom"
            echo "User $cognom added to group $equip."

            # Set permissions for team directory
            chown :"$equip" "/home/$equip/grup"
            chmod 770 "/home/$equip/grup"
            chmod 777 "/home/$equip/public"

            # Create user directory inside team directory
            mkdir "/home/$equip/$cognom"
            chown "$cognom":"$cognom" "/home/$equip/$cognom"
            chmod 700 "/home/$equip/$cognom"
            echo "User directory /home/$equip/$cognom created."

            # Add user to equip_members array
            equip_members["$equip"]="$cognom ${equip_members[$equip]}"
        fi
    done < "$filename"

    # Delete team directories if they are empty
    for equip in "${!equip_members[@]}"; do
        if [ -z "${equip_members[$equip]}" ]; then
            rm -r "/home/$equip"
            echo "Directory /home/$equip deleted."
        fi
    done
fi

