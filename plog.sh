#! /bin/bash

## Checks if help flag is present
if [ "$1" = "--help" -o "$1" = "-h" ]
then
	# Prints help message and exits
	echo "$(cat ./help.txt)"
	exit 0
fi

## Checks if a log file exists
if ! [ -f ./*.log ]
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
	\n
	EOF
	)
	
	# Adds the init message to the log file
	echo -e "$init" > $filename.log

	#### Might add prompt for title and description for start of the log
fi

: '
Might delete title. Not sure yet

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
	cp "*.log" "backup.log"
	
	# Sets file to be any log file that is not the backup
	file=($(find . -name "*.log" -not -name "backup.log"))

	# Removes entry from last up until end of last entry
	sed -i '$,/^\*\*\*/d' "$file"

# Revert to backup flag
elif [ "$1" = "--revert" -o "$1" = "-r" ]
then
	# Finds the name of the original file
	original_file=$(find . -name "*.log" -not -name "backup.log")

	# Counts the number of files found
	file_count=$(echo "$original_file" | wc -l)
	
	# Error handling if there are multiple .log files
	if [ "$file_count" -eq 1 ]
	then
		# Single file found, proceed with the reverting
		original_file=$(echo "$original_file" | tr -d '\n') # removes newline char

		# Overwrite the other file with the backup file
		mv backup.log "$original_file"
		echo "Backup is restored to $original_file"
	else
		# Multiple files found, display error and quit
		echo "Error: Multiple log files found."
		echo "plog can only handle one .log file in current directory"
		echo "Please ensure that there is only one other .log file besides backup.log"
		exit 1
	fi

# Short message flag
elif [ "$1" = "--msg" -o "$1" = "-m" ]
then
	# Coming soon

# No flags detected
else
	# Removes backup if there is one from previously deleting last entry
	rm -f "backup.log"
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
#echo "your input was:"
#echo "$entry"

# Creates timestamp in the format dd.mm.yyyy hh:mm:ss
timestamp=$(date +"%d.%m.%Y %H:%M:%S")

# Redirects the log entry to the log file
# Might add title, not sure
echo -e "\n$timestamp\n$entry\n\n***" >> *.log
