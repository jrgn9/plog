#! /bin/bash

# Script for installing plog

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
    echo "You are about to install version $current_version, but the latest release is $latest_release. Do you still want to continue? y/n"
    read -r proceed_install
else
    echo "You are installing the latest version: $current_version"
fi

# Proceeds to the install process if the user has latest version or answered yes to install old version
if [ "$proceed_install" = "y" ] || [ -z "$proceed_install" ]
then
    echo ""
    
fi