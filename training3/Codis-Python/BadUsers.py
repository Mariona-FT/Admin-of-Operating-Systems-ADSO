import subprocess
import datetime
import re
import sys

def get_max_age(duration):
    unit = duration[-1]
    value = int(duration[:-1])
    if unit == 'd':
        return value
    elif unit == 'm':
        return value * 30
    else:
        raise ValueError("Durada no reconeguda. Utilitzeu 'd' per dies i 'm' per mesos.")

def get_users():
    cmd = "cut -d: -f1 /etc/passwd"
    return subprocess.getoutput(cmd).splitlines()

def get_home_directory(user):
    cmd = f"getent passwd {user} | cut -d: -f6"
    return subprocess.getoutput(cmd)

def user_has_processes(user):
    cmd = f"ps -ef | grep ^{user} | wc -l"
    return int(subprocess.getoutput(cmd)) > 0

def days_since_last_login(user):
    cmd = f"lastlog -u {user}"
    output = subprocess.getoutput(cmd).splitlines()[-1]
    match = re.search(r"\w{3} \w{3} [ \d]{2} [\d:]{5} [\d]{4}", output)
    if match:
        last_login_str = match.group(0)
        last_login_date = datetime.datetime.strptime(last_login_str, "%a %b %d %H:%M:%S %Y")
        now = datetime.datetime.now()
        return (now - last_login_date).days
    return float('inf')

def has_recent_files(user, home, max_age):
    cmd = f"find {home} -type f -user {user} -mtime -{max_age} 2>/dev/null | wc -l"
    return int(subprocess.getoutput(cmd)) > 0

if __name__ == "__main__":
    if len(sys.argv) != 3 or sys.argv[1] != "-t":
        print("Usage: BadUser.py [-t <duration>]")
        sys.exit(1)

    duration = sys.argv[2]
    max_age = get_max_age(duration)

    for user in get_users():
        home = get_home_directory(user)
        if (not user_has_processes(user) and
                days_since_last_login(user) > max_age and
                not has_recent_files(user, home, max_age)):
            print(user)
