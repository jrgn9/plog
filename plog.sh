#! /bin/bash

# Checks if a log file exists
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

	#some start text/metadata here
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

echo "Enter log entry. A Nano text editor will open shortly"
sleep 3
#read -r entry

# Creates a temporary file for log entry
tmpfile=$(mktemp)

# Opens nano text editor
"${EDITOR:-nano}" "$tmpfile"

# Reads content of temporary file to variable
entry=$(cat "$tmpfile")

# Removes the temporary file
rm "$tmpfile"

echo "your input was:"
echo "$entry"
