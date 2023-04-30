# Multi-Server Connection Manager

A simple bash script for managing multiple server connections on Ubuntu. This script allows you to add, connect to, and remove servers, as well as keeping track of the previous server connected to. The script manages `.pem` files for server authentication and ensures correct permissions are set for the `.ssh` directory and `.pem` files.

## Prerequisites

- Ubuntu operating system
- Bash shell
- SSH client

## Installation

1. Clone this repository or download the `multi-server-manager.sh` script.
2. Make sure the script has execute permissions: `chmod +x multi-server-manager.sh`
3. Execute the script: `./multi-server-manager.sh`

## Features

- Checks if the script is running as a regular user, not root.
- Creates the `.ssh` directory with correct permissions if it doesn't exist.
- Scans and moves new `.pem` files from the home directory to the `.ssh` directory and sets correct permissions.
- Provides a menu with the following options:
  - Connect to a new server: Input server IP, username, and select a `.pem` file. Assign a unique name for the server.
  - Connect to an existing server: Displays a list of saved servers and connects to the selected server.
  - Remove a server: Displays a list of saved servers and removes the selected server. Optionally, delete the associated `.pem` file.
  - Reconnect to the previous server: Connects to the last server that was connected to.
  - Quit: Exits the script.

## Usage

Run the script using:

```bash
./multi-server-manager.sh
```

Follow the prompts to add, connect to, or remove servers. The script will display the previous server connected to (if any), and you can reconnect to it if needed.

## Contributing
Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

## License
This project is licensed under the MIT License. See the LICENSE file for details.
