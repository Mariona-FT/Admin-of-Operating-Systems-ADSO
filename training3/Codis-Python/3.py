import os
import sys

p = 0
usage = "Usage: BadUser.py [-p]"

# Detección de opciones de entrada: solo son válidas: sin parámetros y -p
if len(sys.argv) > 1:
    if len(sys.argv) == 2:
        if sys.argv[1] == "-p":
            p = 1
        else:
            print(usage)
            sys.exit(1)
    else:
        print(usage)
        sys.exit(1)

# Agrega una comanda para leer el archivo de contraseñas
# y obtener solo el campo de nombre de usuario
users = [line.split(":")[0] for line in open("/etc/passwd")]

for user in users:
    home = os.path.expanduser("~" + user)
    if os.path.isdir(home):
        num_fich = len([f for f in os.listdir(home) if os.path.isfile(os.path.join(home, f))])
    else:
        num_fich = 0

    if num_fich == 0:
        if p == 1:
            # Agrega una comanda para detectar si el usuario tiene procesos en ejecución
            user_proc = os.popen(f"pgrep -u {user}").read().split()
            if not user_proc:
                print(user)
        else:
            print(user)
