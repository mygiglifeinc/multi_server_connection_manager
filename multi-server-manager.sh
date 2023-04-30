#!/bin/bash

# Multi-server connection manager for Ubuntu

# Check if the script is running as root
if [ "$(whoami)" == "root" ]; then
  echo "Do not run this script as root. Run as a regular user."
  exit 1
fi

SSH_DIR="$HOME/.ssh"
CONFIG_FILE="$SSH_DIR/servers.conf"
PREV_SERVER_FILE="$SSH_DIR/prev_server.txt"

# Create .ssh directory if it doesn't exist and set correct permissions
if [ ! -d "$SSH_DIR" ]; then
  mkdir -p "$SSH_DIR"
  chmod 700 "$SSH_DIR"
fi

# Create servers.conf file if it doesn't exist
if [ ! -f "$CONFIG_FILE" ]; then
  touch "$CONFIG_FILE"
  chmod 600 "$CONFIG_FILE"
fi

# Function to rescan and move new .pem files
rescan_pem_files() {
  find $HOME -maxdepth 1 -type f -name "*.pem" -exec mv -n {} $SSH_DIR \;
  find $SSH_DIR -type f -name "*.pem" -exec chmod 400 {} \;
  find $HOME -type f -name "*.pem:Zone.Identifier" -exec rm {} \;
}

# Initial scan for .pem files
rescan_pem_files

# Function to display list of servers
display_servers() {
  echo "Available servers:"
  awk '{print NR".", $4}' $CONFIG_FILE
}

# Function to connect to the previous server
reconnect_previous_server() {
  if [ -f "$PREV_SERVER_FILE" ]; then
    server_info=($(cat $PREV_SERVER_FILE))
    clear
    ssh -i "$SSH_DIR/${server_info[2]}" "${server_info[0]}@${server_info[1]}"
  else
    echo "No previous server found."
  fi
}

# Main menu
while true; do
  clear

  if [ -f "$PREV_SERVER_FILE" ]; then
    prev_server_name=$(awk '{print $4}' $PREV_SERVER_FILE)
    echo "Previous server: $prev_server_name"
  fi

  echo "Choose an option:"
  echo "1. Connect to a new server"
  echo "2. Connect to an existing server"
  echo "3. Remove a server"
  echo "4. Reconnect to the previous server"
  echo "q. Quit"
  read -p "Enter your choice: " choice

  case "$choice" in
    1)
      clear
      # Rescan for new .pem files
      rescan_pem_files

      # Connect to a new server
      read -p "Enter server IP: " ip
      read -p "Enter username: " username
      echo "Available .pem files:"
      find $SSH_DIR -type f -name "*.pem" -printf "%f\n"
      read -p "Enter .pem file name: " pem_file
      read -p "Enter a unique name for this server: " server_name
      echo "$username $ip $pem_file $server_name" >> $CONFIG_FILE
      echo "$username $ip $pem_file $server_name" > $PREV_SERVER_FILE
      clear
      ssh -i "$SSH_DIR/$pem_file" "$username@$ip"
      ;;
    2)
      clear
      # Connect
  # Connect to an existing server
  display_servers
  read -p "Enter server number to connect: " server_num
  server_info=($(sed "${server_num}q;d" $CONFIG_FILE))
  echo "${server_info[@]}" > $PREV_SERVER_FILE
  clear
  ssh -i "$SSH_DIR/${server_info[2]}" "${server_info[0]}@${server_info[1]}"
  ;;
3)
  clear
  # Remove a server
  display_servers
  read -p "Enter server number to remove: " server_num
  read -p "Are you sure you want to remove this server? (y/n): " confirm
  if [ "$confirm" == "y" ]; then
    server_info=($(sed "${server_num}q;d" $CONFIG_FILE))
    read -p "Do you want to delete the associated .pem file? (y/n): " del_pem
    if [ "$del_pem" == "y" ]; then
      rm -f "$SSH_DIR/${server_info[2]}"
    fi
    sed -i "${server_num}d" $CONFIG_FILE
    echo "Server removed."
    ssh-keygen -R "${server_info[1]}"
  fi
  ;;
4)
  clear
  # Reconnect to the previous server
  reconnect_previous_server
  ;;
q)
  # Quit
  exit 0
  ;;
*)
  clear
  echo "Invalid option. Try again."
  ;;
esac
done
