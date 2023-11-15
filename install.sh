#! /bin/bash

# Script for installing plog

# Extract the home folder of the user who is logged in (since sudo makes $HOME to root)
USER_HOME=$(getent passwd $(logname) | cut -d: -f6)

# Defining repository details
USER="jrgn9"
REPO="plog"
current_version="v1.0.0-alpha"

# Checks if the user runs the install script as sudo
if [ ! -w /usr/local/bin ]
then
    echo "Error: Please run this script with sudo so plog can be installed to /usr/local/bin"
    exit 1
fi

# MAKE CURL OPTIONAL WITH WARNING THAT IT CAN'T CHECK VERSION WITHOUT IT

# Check that the user has curl installed
if ! command -v curl &> /dev/null
then
    echo "Please install curl to proceed"
    exit 1
fi

# Fetch latest release tag from GitHub via their api
latest_release=$(curl -s "https://api.github.com/repos/$USER/$REPO/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')

# Compare versions
if [ "$latest_release" != "$current_version" ]
then
    echo "You are about to install version $current_version, but the latest release is $latest_release. You can find the latest version at https://github.com/$USER/$REPO/releases"
    read -rp "Do you still want to continue? (y/n): " proceed_install
    if [ "$proceed_install" != "y" ]
    then
        echo "Installation aborted"
        exit 1
    fi
else
    echo "You are installing the latest version: $current_version"
fi

# Proceeds to the install process 
if [ -d "$USER_HOME/.plog" ]
then
    echo ".plog directory already exists. All existing program files, including settings, will be overwritten. Backups will not be affected"
else
    echo "Creating .plog directory for program files in $USER_HOME"
    mkdir "$USER_HOME/.plog"
fi

echo "Moving program files to $USER_HOME/.plog"
mv program_files/* "$USER_HOME/.plog/"
cp README.md "$USER_HOME/.plog/"

# Change the ownership from root (because of sudo) to the user
chown -R $(logname):$(logname) "$USER_HOME/.plog"

echo "Giving plog the right permissions"
chmod 755 plog

echo "Moving plog program to /usr/local/bin. Older versions of the program will be overwritten"
mv plog /usr/local/bin

echo "Installation complete. Run 'plog -h' in terminal for help or read the documentation"