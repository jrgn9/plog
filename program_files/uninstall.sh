#! /bin/bash

# Script for uninstalling plog

# Extract the home folder of the user who is logged in (since sudo makes $HOME to root)
USER_HOME=$(getent passwd $(logname) | cut -d: -f6)

# Checks if the user runs the install script as sudo
if [ ! -w /usr/local/bin ]
then
    echo "Error: Please run this script with sudo so plog can be installed to /usr/local/bin"
    exit 1
fi

# Prompt for confirmation of uninstall
read -rp "Are you sure you want to uninstall plog? (y/n): " confirm_uninstall
if [ "$confirm_uninstall" != "y" ]
then
    echo "Uninstallation aborted"
    exit 1
fi

# Prompt for backup handling
read -rp "Do you want to keep the backups? (y/n): " keep_backups
if [ "$keep_backups" != "y" ]
then
    echo "Keeping backups in $USER_HOME/.plog. Deleting all other plog files"

    # Find and delete all fines in .plog directory except backups
    find "$USER_HOME/.plog" -mindepth 1 -maxdepth 1 -type d -name 'backup' -prune -o -exec rm -rf {} +

else
    echo "Deleting all plog files including backups"

    # Delete entire .plog directory
    rm -rf "$USER_HOME/.plog"
fi

# Remove plog from /usr/local/bin
echo "Removing plog from /usr/local/bin"
rm -f /usr/local/bin/plog

echo "plog has been successfully uninstalled"