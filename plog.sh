#! /bin/bash

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
Might delete title. Not sure yet. Might also add author

echo "Enter entry title (not mandatory. Default: None) - Ctrl+D to finish"
read -r input_title
if [ "$input_title" -ne "" ]
then
	title=$input_title
fi
'

## Flag checks
# Delete last entry flag
if [ "$1" = "--dlast" -o "$1" = "-dl" ]
then

	# Creates a backup before removing last entry
	cp "$logfile" backup.log

	# Removes entry from last up until end of previous entry
	
	tac "$logfile" | awk -v RS='~~~~~~' 'NR > 1 { print }' | tac > tmpfile && mv tmpfile "$logfile"

	#awk 'BEGIN { RS = "***\n"; ORS = "***\n" } NR > 1 { print prev } { prev = $0 } END { printf "%s", prev }' "$logfile" > tmpfile && mv tmpfile "$logfile"

	### Resulted in only ****************************
	#awk -v RS="***" 'NR > 1 {printf "%s***", prev} {prev=$0} END {printf "%s", prev}' "$logfile" > tmpfile && mv tmpfile "$logfile"
	
	### Deletes every entry
	#sed -i -e :a -e '$!N; $!ba' -e '/^\*\*\*/,$d' "$logfile"
	
	### Deletes every *** and the entries in the middle
	#sed -i '/^\*\*\*$/,/^\*\*\*$/d' "$logfile"
	
	### Deletes every *** except the last
	#sed -i '$!N; /^\*\*\*\n$/!P; D' "$logfile"
	
	### Deletes every *** in the document
	#sed -i '/^\*\*\*$/,/^.*$/d' "$logfile"
	
	### Deletes the last entry and every *** as well as some entries in between
	#tac "$logfile" | sed '/^\*\*\*$/,/^.*\*\*\*$/d' | tac > tmpfile && mv tmpfile "$logfile"
	exit 0

# Revert to backup flag
elif [ "$1" = "--revert" -o "$1" = "-r" ]
then
	# Overwrite the other file with the backup file
	mv backup.log "$logfile"
	echo "Backup is restored to $logfile"
	exit 0

# Short message flag
elif [ "$1" = "--msg" -o "$1" = "-m" ]
then
	# Coming soon
	# Removes backup if there is one from previously deleting last entry
	rm -f backup.log
else
	# No flags detected
	# Removes backup if there is one from previously deleting last entry
	rm -f backup.log
	echo -e "Enter log entry. A Nano text editor will open shortly \nCtrl+S to save, Ctrl+X to quit"
	sleep 1.5

	# Creates a temporary file for log entry
	tmpfile=$(mktemp)

	# Opens nano text editor
	"${EDITOR:-nano}" "$tmpfile"

	# Reads content of temporary file to variable
	entry=$(cat "$tmpfile")

	# Removes the temporary file
	rm "$tmpfile"
fi

# Creates timestamp in the format dd.mm.yyyy hh:mm:ss
timestamp=$(date +"%d.%m.%Y %H:%M:%S")

# Redirects the log entry to the log file
# Might add title, not sure
# Might change the delimiter
echo -e "\n$timestamp\n$entry\n\n~~~~~~" >> "$logfile"
