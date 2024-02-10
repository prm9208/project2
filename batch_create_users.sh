#!/bin/bash
show_usage() {
    echo "Usage: $0 -u username1 username2 ... | -f filename"
    echo "-u: Specify usernames separated by spaces."
    echo "-f: Specify a file containing usernames."
    echo "--help: Display this help message."
}

while getopts "u:f:--help" option; do
  case "$option" in
    u) IFS=' ' read -r -a usernames <<< "${OPTARG}" ;;
    f) IFS=$'\n' read -d '' -r -a usernames < "${OPTARG}" ;;
    --help) show_usage; exit 0 ;;
    *) show_usage; exit 1 ;;
  esac
done

for username in "${usernames[@]}"; do
  if getent passwd "$username" > /dev/null; then
    echo "User $username already exists."
    continue
  fi

  # Add user condition checks here (e.g., regex for valid username)

  # Create user
  useradd -m -s /bin/bash "$username" && echo "User $username created."

  # Generate a random password
  password=$(openssl rand -base64 12)

  # Set the password for the user
  echo "$username:$password" | chpasswd

  # Force password change on first login
  chage -d 0 "$username"

  # Output username and password
  echo "$username:$password" >> users_credentials.txt

  # If script, disable the user (for this assignment)
  usermod -L "$username" # Lock the password
done

