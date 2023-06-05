#! /bin/bash

if ! [ -f ./*.log ]
then
	echo "No log file detected \n
	Enter name for new log file (default: p.log)"
	read filename
	echo "Creating file $filename.log in current directory"
	touch "$filename.log"

	#some start text/metadata here
fi

echo "Enter entry title (not mandatory. Default: None"
read input_title
if [ $1 ]

echo ""
