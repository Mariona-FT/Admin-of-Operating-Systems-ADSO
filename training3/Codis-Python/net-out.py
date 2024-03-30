import os
import time
import sys

def get_network_interface_stats():
    # Obtenir les dades de /proc/net/dev
    with open('/proc/net/dev', 'r') as f:
        net_dump = f.readlines()

    # Diccionari per emmagatzemar les dades de les interfícies
    interface_data = {}

    # Processar cada línia, ignorar les dues primeres
    for line in net_dump[2:]:
        line = line.strip()
        if line:
            parts = line.split()
            interface = parts[0].rstrip(':')
            transmit_packets = int(parts[9])  # Els paquets transmesos estan en la desena posició
            interface_data[interface] = transmit_packets

    return interface_data

def main(interval):
    while True:
        # Obtenir les dades de les interfícies
        stats = get_network_interface_stats()
        total_packets = sum(stats.values())

        # Imprimir les dades
        for interface, packets in stats.items():
            print(f"{interface}: \t{packets}")
        print(f"Total:\t{total_packets}\n")

        # Esperar N segons
        time.sleep(interval)

if __name__ == "__main__":
    # Comprovar si s'ha proporcionat un interval
    if len(sys.argv) != 2:
        print("Usage: net-out.py <interval_in_seconds>")
        sys.exit(1)

    # Executar el bucle principal amb l'interval especificat
    main(int(sys.argv[1]))
