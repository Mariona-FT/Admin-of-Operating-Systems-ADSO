import subprocess

def get_login_summary():
    login_summary = {}
    output = subprocess.check_output(["last"]).decode("utf-8")
    lines = output.splitlines()
    for line in lines:
        if "logged in" in line:
            fields = line.split()
            username = fields[0]
            login_time = int(fields[9])
            if username in login_summary:
                login_summary[username]["login_count"] += 1
                login_summary[username]["total_login_time"] += login_time
            else:
                login_summary[username] = {
                    "login_count": 1,
                    "total_login_time": login_time
                }
    return login_summary

def get_active_users_summary():
    active_users_summary = []
    ps_output = subprocess.check_output(["ps", "-e", "-o", "user,pcpu"]).decode("utf-8")
    lines = ps_output.splitlines()[1:]
    for line in lines:
        fields = line.split()
        username = fields[0]
        cpu_percentage = float(fields[1])
        process_count = 1
        if any(user["user"] == username for user in active_users_summary):
            index = next((index for (index, d) in enumerate(active_users_summary) if d["user"] == username), None)
            active_users_summary[index]["process_count"] += 1
            active_users_summary[index]["cpu_percentage"] += cpu_percentage
        else:
            active_users_summary.append({
                "user": username,
                "process_count": process_count,
                "cpu_percentage": cpu_percentage
            })
    return active_users_summary

def print_summary(login_summary, active_users_summary):
    print("Resum de logins:")
    for username, info in login_summary.items():
        print(f"Usuari {username}: temps total de login {info['total_login_time']} min, nombre total de logins: {info['login_count']}")
    print("\nResum d'usuaris connectats")
    for user_info in active_users_summary:
        print(f"Usuari {user_info['user']}: {user_info['process_count']} processos -> {user_info['cpu_percentage']}% CPU")

if __name__ == "__main__":
    login_summary = get_login_summary()
    active_users_summary = get_active_users_summary()
    print_summary(login_summary, active_users_summary)