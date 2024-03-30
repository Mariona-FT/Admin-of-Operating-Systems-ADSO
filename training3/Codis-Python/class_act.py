import os
import sys
import datetime
import pwd

def classify_activity(n, user_name):
    try:
        user_info = pwd.getpwnam(user_name)
    except KeyError:
        print("L'usuari no existeix.")
        return

    user_home = user_info.pw_dir
    user_initials = user_name.split()[0][0].lower()

    # Calcular la data límit com n dies enrere a partir de la data actual
    limit_date = (datetime.datetime.now() - datetime.timedelta(days=n)).timestamp()

    file_count = 0
    total_size = 0

    for root, dirs, files in os.walk(user_home):
        for file in files:
            file_path = os.path.join(root, file)
            try:
                file_stat = os.stat(file_path)
            except FileNotFoundError:
                continue  # Ignorar fitxers que no existeixen
            file_modification_time = file_stat.st_mtime

            if file_modification_time >= limit_date:
                file_count += 1
                total_size += file_stat.st_size

    total_size_mb = total_size / (1024 * 1024)

    print(f"{user_name} ({user_initials}) {file_count} fitxers modificats que ocupen {total_size_mb:.1f} MB")

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Ús: python class_act.py <n> <Nom i Cognom de l'usuari>")
        sys.exit(1)

    n = int(sys.argv[1])
    user_name = sys.argv[2]

    classify_activity(n, user_name)
