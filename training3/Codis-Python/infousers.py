import os
import sys
import pwd

usage = "Usage: InfoUsers.py <username>"

# Check the number of arguments
if len(sys.argv) != 2:
    print(usage)
    sys.exit(1)

username = sys.argv[1]  # Get the provided username

# Check if the user exists by looking at the /etc/passwd file
try:
    pwd.getpwnam(username)
except KeyError:
    print(f"User {username} does not exist.")
    sys.exit(1)

# Get the user's home directory
home_dir = os.path.expanduser(f"~{username}")

if not os.path.exists(home_dir) or not os.path.isdir(home_dir):
    print(f"User {username} does not have a home directory.")
    sys.exit(1)

# Get the size of the user's home directory
home_size = os.popen("/usr/bin/du -sh {0}".format(home_dir)).read().split()[0]

# Find other directories owned by the user
other_dirs = []
for root, dirs, files in os.walk('/'):
    for directory in dirs:
        path = os.path.join(root, directory)
        if os.path.isdir(path) and os.stat(path).st_uid == os.stat(home_dir).st_uid:
            other_dirs.append(path)

# Count the number of active processes for the user
user_proc = os.popen("/usr/bin/pgrep -u {0}".format(username)).read().split()
active_proc = len(user_proc)

print(f"Home: {home_dir}")
print(f"Home size: {home_size}")
print(f"Other dirs: {other_dirs}")
print(f"Active processes: {active_proc}")
