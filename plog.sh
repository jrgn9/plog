#! /bin/bash

# Fetches settings from .config
source .config

# In the bin file I need to use pwd to find current directory for it to be right

## Checks if help flag is present
if [ "$1" = "--help" -o "$1" = "-h" ]
then
	# Prints help message and exits
	echo "$(cat ./help.txt)"
	exit 0
fi

## Error handling for logs
# Finds all .log files except backup.log
logs=$(find . -name "*.log" -not -name "backup.log")

# Counts the number of files found
file_count=$(echo "$logs" | wc -l)
	
# Error handling if there are multiple .log files
if [ "$file_count" -gt 1 ]
then
	# Multiple files found, display error and quit
	echo "Error: Multiple log files found."
	echo "plog can only handle one .log file in current directory"
	echo "Please ensure that there is only one other .log file besides backup.log"
	exit 1

elif [ -z "$logs" ]
# Error handling If there are no log files
then
	# Prompts user for file name
	echo -e "No log file detected \nEnter name for new log file (default: p.log)"
	read filename
	
	# If no name is entered, default is p
	if [ -z "$filename" ]
	then
		filename=p
	fi
	
	# Prints filename and creates file
	echo "Creating file $filename.log in current directory"
	touch "$filename.log"

	# Adding start of the document by using Here Document for multi-line
	# Maybe add this as an seperate document in the install version to be able to edit
	# the init message?
	init=$(cat <<-EOF
	****************************************
	THIS IS A LOG FILE CREATED BY PLOG
	IN TERMINAL: 'plog --help' FOR HELP MENU
	OR SEE README FOR DOCUMENTATION
	****************************************

	---START OF LOG---
	EOF
	)
	
	# Adds the init message to the log file
	echo -e "$init" > $filename.log

	#### Might add prompt for title and description for start of the log
fi

## Set logfile to be the file found in current directory
logfile=$(find . -name "*.log" -not -name "backup.log")

: '
Might delete title. Not sure yet.

echo "Enter entry title (not mandatory. Default: None) - Ctrl+D to finish"
read -r input_title
if [ "$input_title" -ne "" ]
then
	title=$input_title
fi
'


# If I want to prompt user for author every time
# Needs to be added in msg and else if I want to use it
: '
elif [ ! -f ".config" -o "$author" = "$(whoami)"]
then
	read -p "Enter author name (use plog --author to set new default name) " author
fi

'

## Flag checks
# Delete last entry flag
if [ "$1" = "--dlast" -o "$1" = "-dl" ]
then

	# Creates a backup before removing last entry
	# IN THE BIN FILE SET THE PATH TO ~/.plog/backup.log
	cp "$logfile" backup.log

	# Removes entry from last up until end of previous entry
	
	awk -v RS="\n\n~~~~~~\n" 'BEGIN{ORS=RS} NR>1 {print prev} {prev=$0} END{}' "$logfile" > temp && mv temp "$logfile"

	# Check if the file was modified and prints message
	if [[ $? -eq 0 ]]
	then
		echo "Last entry deleted"
	else
		echo "There are no entries to delete"
	fi

	exit 0

# Revert to backup flag
elif [ "$1" = "--revert" -o "$1" = "-r" ]
then
	# Overwrite the other file with the backup file
	# IN THE BIN FILE SET THE PATH TO ~/.plog/backup.log
	mv backup.log "$logfile"
	echo "Backup is restored to $logfile"
	exit 0

# Change author flag
elif [ "$1" = "--author" -o "$1" = "-a" ]
then
	# Prompt user for name
	read -p "Enter author name: " author
	
	# THIS MIGHT BE FUCKED BECAUSE OF $(whoami) - FOLLOW UP!!!!
	# Update author in the .config file
	sed -i "s/author=.*/author=\"$author\"/" .config

	# Source the updated .config file
	source .config

	echo "Author: $author saved in config"
	echo "To edit author use plog --author or edit the .config file manually"

# Short message flag
elif [ "$1" = "--msg" -o "$1" = "-m" ]
then	
	# Removes backup if there is one from previously deleting last entry
	# THIS CAN BE REMOVED WHEN BACKUP IS MOVED TO .plog FOLDER AFTER INSTALL
	rm -f backup.log
	
	# This might be rewritten using 'getopts', but I think this way is sufficent
	entry="$2"
	
	# Checking if the message is in double quotes and not empty
	if [[ $2 != \"*\" || $2 != *\" ]]
	then
		if [[ $2 != "\"\"" ]]
		then
			echo "Error: Message should be enclosed in double quotes"
			exit 1
		else
			echo "Error: Message cannot be empty"
			exit 1
		fi
	else
		# The input is valid and added to the logfile. Success message to user.
		#### Might need to fix this in the binary file later
		echo "Entry added to ${logfile:2}"
	fi
else
	# No flags detected
	# Removes backup if there is one from previously deleting last entry
	# THIS CAN BE REMOVED WHEN BACKUP IS MOVED TO .plog FOLDER AFTER INSTALL
	rm -f backup.log

	echo -e "Enter log entry. A Nano text editor will open shortly \nCtrl+S to save, Ctrl+X to quit"

	# Sleep so the user have time to read text. Time set in .config (default: 1.5s)
	sleep $editor_delay

	# Creates a temporary file for log entry
	tmpfile=$(mktemp)

	# Opens default text editor set in .config (default: nano)
	"$text_editor" "$tmpfile"

	# Reads content of temporary file to variable
	entry=$(cat "$tmpfile")

	# Removes the temporary file
	rm "$tmpfile"
fi

# ADDED THIS TO .config
# Creates timestamp in the format dd.mm.yyyy hh:mm:ss
#timestamp=$(date +"%d.%m.%Y %H:%M:%S")

# Redirects the log entry to the log file
# Might add title, not sure
# Might change the delimiter
echo -e "\n$timestamp\nAuthor: $author\n\n$entry\n\n~~~~~~" >> "$logfile"
