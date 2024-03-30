#!/usr/bin/env python3
import os
import subprocess
import sys
import grp
import pwd

def convert_size(size):
    # Converteix la mida a kb
    units = {"K": 1, "M": 1024, "G": 1024**2}
    number, unit = size[:-1], size[-1]
    return int(number) * units[unit.upper()]

def format_size(size_kb):
    # Posa la mida en el format més adient
    if size_kb >= 1048576:  # >= 1 GB
        return f"{size_kb / 1048576:.2f} GB"
    elif size_kb >= 1024:  # >= 1 MB
        return f"{size_kb / 1024:.2f} MB"
    else:  # Less than 1 MB
        return f"{size_kb} KB"

def check_usage(home_dir, max_permitted_kb):
    # Comprova l'ús del disc d'un directori home
    du_output = subprocess.check_output(['du', '-sk', home_dir]).split()
    usage_kb = int(du_output[0].decode('utf-8'))
    formatted_usage = format_size(usage_kb)
    
    user = os.path.basename(home_dir)
    print(f"{user}\t\t{formatted_usage}")
    
    # Si la mida d'ús ha excedit el límit, adjunta el missatge al .profile de l'usuari
    if usage_kb > max_permitted_kb:
        profile_path = os.path.join(home_dir, '.profile')
        with open(profile_path, 'a') as profile:
            profile.write("\nHas sobrepassat l'espai de disc permès. Si us plau, esborra o comprimeix alguns dels teus fitxers.\n")

def get_group_members(group_name):
    # Retorna una llista dels noms d'usuari dels membres del grup
    try:
        gid = grp.getgrnam(group_name).gr_gid
        members = [pwd.getpwuid(u.pw_uid).pw_name for u in pwd.getpwall() if u.pw_gid == gid]
        return members
    except KeyError:
        print(f"El grup '{group_name}' no existeix.")
        sys.exit(2)

def check_group_usage(group_name, max_permitted_kb):
    # Comprova l'ús del disc per a tots els membres d'un grup
    members = get_group_members(group_name)
    total_kb = 0
    
    for user in members:
        home_dir = os.path.join('/home', user)
        if os.path.isdir(home_dir):
            du_output = subprocess.check_output(['du', '-sk', home_dir]).split()
            usage_kb = int(du_output[0].decode('utf-8'))
            total_kb += usage_kb
            check_usage(home_dir, max_permitted_kb)
    
    print(f"Total grup {group_name}: {format_size(total_kb)}")

def main():
    if len(sys.argv) < 2 or len(sys.argv) > 4:
        print("Ús: {} [-g grup] max_permès".format(sys.argv[0]))
        print("max_permès ha de ser un valor seguit de K, M o G (per exemple, 600M)")
        sys.exit(1)
    
    group_name = ""
    if "-g" in sys.argv:
        g_index = sys.argv.index("-g")
        group_name = sys.argv[g_index + 1]
        max_permitted = sys.argv[g_index + 2]
    else:
        max_permitted = sys.argv[1]
    
    max_permitted_kb = convert_size(max_permitted)
    
    if group_name:
        check_group_usage(group_name, max_permitted_kb)
    else:
        # Llista de tots els directoris usuaris home que es troben a /home
        for home_dir in os.listdir('/home'):
            full_path = os.path.join('/home', home_dir)
            if os.path.isdir(full_path):
                check_usage(full_path, max_permitted_kb)

if __name__ == "__main__":
    main()

