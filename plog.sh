#! /bin/bash

if ! [ -f ./*.log ]
then
	echo -e "No log file detected \n
	Enter name for new log file (default: p.log)"
	read filename
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

echo "Enter log entry. Multi-line is supported (Ctrl+D to finish)"
read -r entry


