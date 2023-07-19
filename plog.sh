#! /bin/bash

# Fetches settings from .config
source config

# Finds current directory
current_directory="$(pwd)"

## CHECKS FOR META FLAGS
# HELP FLAG
if [ "$1" = "--help" -o "$1" = "-h" ]
then
	# Prints help message and exits
	# FIX PATH FOR THIS AFTER INSTALLER
	cat help.txt
	exit 0

# ABOUT FLAG
elif [ "$1" = "--about" ]
then
	# FIX PATH FOR THIS AFTER INSTALLER
	cat about.txt
	exit 0

# SETTINGS FLAG
elif [ "$1" = "--settings" ]
then
	# Opens config file in default text editor
	# FIX PATH AFTER INSTALLER
	"$text_editor" config
	exit 0

# INIT FLAG
elif [ "$1" = "--init" ]
then
	# Opens init file in default text editor
	# FIX PATH AFTER INSTALLER
	"$text_editor" init.txt
	exit 0

# UNINSTALL FLAG
elif [ "$1" = "--uninstall" ]
then
	echo "An uninstall script will run when this is done"
	exit 0
fi

## ERROR HANDLING FOR LOGS
# Finds all .log files except backup.log
### In the bin file I need to use pwd to find current directory for it to be right
logs=$(find "$current_directory" -name "*.log" -not -name "*.backup.log")

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
	echo -e "No log file detected \nDo you want to add a new log file? y/n"
	read answer

	if [ "$answer" = "y" -o "$answer" = "Y" -o "$answer" = "yes" ]
	then
		echo "Enter name for new log file (default: p.log)"
		read filename
	
		# If no name is entered, default is p
		if [ -z "$filename" ]
		then
			filename=p
		fi
	
		# Prints filename and creates file
		echo "Creating file $filename.log in current directory"
		touch "$filename.log"

		read -p "Enter title for the document: " title

		# Adds the init message and title to the log file
		cat ./init.txt > $filename.log
		echo -e "---START OF LOG---\n" >> $filename.log
		echo -e "$title" >> $filename.log
		echo -e "\n~~~~~~" >> $filename.log

		#### Might add prompt for description for start of the log
	else
		echo "No log file created"
		exit 1
	fi
fi

## Set logfile to be the file found in current directory
### In the bin file I need to use pwd to find current directory for it to be right
logfile=$(find "$current_directory" -name "*.log" -not -name "*.backup.log")


# ADD ENTRY ID
# Uses grep and awk to search for last entry number. Extracts number from # and sorts the numbers
last_entry_number=$(grep -o "Entry #[0-9]*" "$logfile" | awk -F '#' '{print $NF}' | sort -n | tail -n 1)

# If there is a last entry number
if [ -n "$last_entry_number" ]
then
	# New entry number is last + 1
	entry_number=$((last_entry_number + 1))
else
	# If there are no last entry number, entry number is 1
	entry_number=1
fi


## FLAG CHECKS

# DELETE ENTRY FLAG
if [ "$1" = "--delete" -o "$1" = "-d" ]
then
	# Creates a backup before deleting entries
	# IN THE BIN FILE SET THE PATH TO ~/.plog/backup.log
	cp "$logfile" "$logfile".backup.log

	# Checks if there are any entries (skipping the init message)
	# REMEMBER: UPDATE NR IF I CHANGE INIT MESSAGE!!!!
	if [[ $(awk 'NR>10' "$logfile") == "" ]]
	then
		echo "There are No entries to delete"
		exit 1
	else
		if [ -z "$2" ]
		then
			# Invokes the program recursively if the user haven't provided a second argument
			read -p "Do you want to delete by id or the last entry? (id/last):" answer
			# THIS NEEDS TO BE UPDATED WHEN THE PROGRAM IS FINNISHED!
			"./plog.sh" -d "$answer"

		elif [ "$2" = "last" ]
		then
			# Uses awk and delimiter to seperate entries, and copies everything
			# except the last one to a temporary file, then overwrites the log with it
			awk -v RS="\n\n~~~~~~\n" 'BEGIN{ORS=RS} NR>1 {print prev} {prev=$0} END{}' "$logfile" > tmpfile && mv tmpfile "$logfile"

			# Check if the file was modified and prints message accordingly
			if [[ $? -eq 0 ]]
			then
				
				echo "Entry #$last_entry_number deleted"
			else
				echo "Could not delete last entry"
			fi
		
		elif [ "$2" = "id" -o "$2" = "ID" ]
		then
			# Checks if id is provided as argument
			if [ -n "$3" ]
			then
				# Sets searchid to be Entry # and third argument
				delete_id="Entry #$3"
			
			else
				# Sets searchid to be Entry # and the provided number
				echo "Delete by entry number"
				read -p "Enter entry number to delete: " deleteidnumber
				delete_id="Entry #$deleteidnumber"
			fi


			awk -v RS="\n\n~~~~~~\n" -v delete_id="$delete_id" 'tolower($0) ~ "(^|[^0-9])" tolower(delete_id) "([^0-9]|$)" { next } { print prev "\n\n~~~~~~" } { prev = $0 } END { print prev }' "$logfile" > tmpfile && mv tmpfile "$logfile"
		
			# Check if the file was modified and prints message accordingly
			if [[ $? -eq 0 ]]
			then
				
				echo "$delete_id deleted"
			else
				echo "Could not delete $delete_id"
			fi
		fi

		exit 0
	fi

# REVERT TO BACKUP FLAG
elif [ "$1" = "--revert" -o "$1" = "-r" ]
then
	# Overwrite the other file with the backup file
	# IN THE BIN FILE SET THE PATH TO ~/.plog/backup.log
	mv "$logfile".backup.log "$logfile"
	echo "Backup is restored to $logfile"
	exit 0

# CHANGE AUTHOR FLAG
elif [ "$1" = "--author" -o "$1" = "-a" ]
then
	# Prompt user for name
	read -p "Enter author name: " author
	
	# Checks if user provided author name
	if [ -z "$author" ]
	then
		echo "Error: No author name provided. Author not changed"
		exit 1
	
	elif [ "$author" = "user" -o "$author" = "User" ]
	then
		sed -i "s/author=.*/author=\$(whoami)/" config
		
		source config
		
		echo "Author successfully reverted to computer user name: $author"
		
		exit 0
	fi
	
	# Update author in the .config file
	sed -i "s/author=.*/author=\"$author\"/" config

	# Source the updated .config file
	source config
	
	# Author successfully added
	echo "Author: $author saved in config"
	echo "To edit author use plog --author or edit the .config file manually"
	exit 0

# IMPORT FLAG
elif [ "$1" = "--import" -o "$1" = "-i" ]
then
	# Checks if user has provided file as argument to skip being prompted
	if [ -e "$2" ]
	then
		filename="$2"
	else
	
		echo "Enter the file name or relative path of the file to import (default: $current_directory/):"
		read filename
	fi
	
	# If the user didn't provide a filename, use the current directory as the default
	if [ -z "$filename" ]
	then
		filepath="$current_directory/"
	else
		# Combine the filename with the current directory to form the relative path
		filepath="$current_directory/$filename"
	fi

	# Redirects content of the file to a tempfile
	cat $filepath > tmpfile
	
	# Checks if there are content in the tempfile
	if [ -s tmpfile ]
	then
		# Sets entry to be the content of the file
		entry=$(cat tmpfile)
		rm tmpfile
	else
		# No content in the file/wrong path
		echo "No file with content found. Did you write the right path? Try again."
		rm tmpfile
		exit 1
	fi

# EDIT FLAG
elif [ "$1" = "--edit" -o "$1" = "-e" ]
then
	# Creates a backup before editing entries
	# IN THE BIN FILE SET THE PATH TO ~/.plog/backup.log
	cp "$logfile" "$logfile".backup.log
	
	# Edit arguments
	if [ "$2" = "date" ]
	then
		# Edit by date argument
		
		# Checks if there is a date provided as argument
		if [ -n "$3" ]
		then
			# Sets editdate to be third argument
			editdate="$3"
		else
			# No third argument, prompts user for date
			echo "Edit by date"
			read -p "Enter date in format YYYY-MM-DD: " editdate
		fi	
		
		# Awk sentence that redirects all matching dates to a tempfile
        	awk -v RS="\n\n~~~~~~\n" -v date="$editdate" '$0 ~ date { print $0 "\n\n~~~~~~" }' "$logfile" > tmpfile
		# If there is content in the tempfile, open it in the editor
        	if [ -s "tmpfile" ]
       		then
			# Open temp file with matching entries in default text editor
			"$text_editor" "tmpfile"
            
            		# Ask the user if they want to save the changes
            		read -p "Do you want to save the changes? (y/n): " save_changes
			
			if [ "$save_changes" = "y" ]
			then
				# Get the edited entries from the tmp file
				edited_entries=$(awk -v RS="\n\n~~~~~~\n" '{print}' "tmpfile")
				
				# Check if any dates were modified in the edited content
				edited_dates=$(echo "$edited_entries" | awk -v RS="\n\n~~~~~~\n" -v date="$editdate" 'BEGIN { FS = "\n" } $0 ~ date { print substr($0, 1, 10); exit }')
				
				# Checks if the edited dates matches the date provided (users can't edit dates)
				if [ "$edited_dates" != "$editdate" ]
         			then
					echo "Error: Dates cannot be modified. Changes not saved."
					echo "Please ensure that you do not modify the date during editing."
					rm tmpfile
					exit 1

				else
					# Awk sentence to overwrite entries with matching dates in the original log file
					awk -v RS="\n\n~~~~~~\n" -v date="$editdate" -v entries="$edited_entries" '{
					if ($0 ~ date) {
						print entries
					} else {
						print $0 "\n\n~~~~~~"
						}
				    	}' "$logfile" > tmpfile2 && mv tmpfile2 "$logfile"
				    
				    	echo "Changes saved."
				fi
			else
				# User do not want to save changes
				echo "Changes discarded."
			fi
			
			# Remove the temporary file
			rm tmpfile
        	else
			# If there are no entries found for the provided date, display a message
			echo "No entries found for the provided date. Check if you have used the correct date format."
			rm tmpfile
			exit 1
		fi

		exit 0
	
	elif [ "$2" = "id" -o "$2" = "ID" ]
	then
		# Edit by id argument
		echo "Edit by id"
		exit 0

	elif [ "$2" = "last" ]
	then
		# Edit last entry
		echo "Edit last entry"
		exit 0

	else
		# No arguments

		# Opens the log file with the default editor
		"$text_editor" "$logfile"
		exit 0
	fi

# PRINT FLAG
elif [ "$1" = "--print" -o "$1" = "-p" ]
then
	# Checks if there is a date flag for printing by date
	if [ "$2" = "date" ]
	then
		# Checks if there is a date provided as argument
		if [ -n "$3" ]
		then
			# Sets printdate to be third argument
			printdate="$3"
		else
			# No third argument, prompts user for date
			read -p "Enter date in format YYYY-MM-DD: " printdate
		fi

		# Awk sentence that redirects all matching dates to a tempfile
		# For some reason it considers the init text to be a part of the first entry
		awk -v RS="\n\n~~~~~~\n" -v date="$printdate" '$0 ~ date { print $0 "\n\n~~~~~~" }' "$logfile" >> tmpfile

		# If there is content in the tempfile, print and remove file
		if [ -s "tmpfile" ]
		then
			cat tmpfile
			rm tmpfile
			exit 0
		else
			# If there are no content in the tempfile exit
			echo "No entries found for the provided date. Check if you have used the correct date format"
			rm tmpfile
			exit 1
		fi

	elif [ "$2" = "id" -o "$2" = "ID" ]
	then
		# If the print by id argument is added
		
		# Checks if id is provided as argument
		if [ -n "$3" ]
		then
			# Sets searchid to be Entry # and third argument
			searchid="Entry #$3"
		
		else
			# Sets searchid to be Entry # and the provided number
			read -p "Enter entry number: " searchidnumber
			searchid="Entry #$searchidnumber"
		fi

		# Awk sentence that redirects all matching entries to a tempfile based on the entry id
		# The id number is match exactly on the given number
		awk -v RS="\n\n~~~~~~\n" -v search="$searchid" 'tolower($0) "(^|[^0-9])" ~ tolower(search) "([^0-9]|$)" { print $0 "\n\n~~~~~~" }' "$logfile" >> tmpfile
		
		# If there is content in the tempfile, print and remove files
		if [ -s "tmpfile" ]
		then
			cat tmpfile
			rm tmpfile
			exit 0
		else
			# If there are no entries matching the search, exit
			echo "No entries found matching the entry number."
			exit 1
		fi

		exit 0

	elif [ "$2" = "search" ]
	then
		# If the print by search argument is added

		# Checks if there is a search string provided
		if [ -n "$3" ]
		then
			# Sets searchstring to be the third argument
			searchstring="$3"
		else
			read -p "Enter search string: " searchstring
		fi

		# Awk sentence that redirects all matching entries to a tempfile based on the search string
		# The search string is matched anywhere in the entry
		awk -v RS="\n\n~~~~~~\n" -v search="$searchstring" 'tolower($0) ~ tolower(search) { print $0 "\n\n~~~~~~" }' "$logfile" >> tmpfile
		
		# If there is content in the tempfile, print and remove files
		if [ -s "tmpfile" ]
		then
			cat tmpfile
			rm tmpfile
			exit 0
		else
			# If there are no entries matching the search, exit
			echo "No entries found matching the search string."
			exit 1
		fi
	
	elif [ "$2" = "author" ]
	then
		# If the print by author argument is added
	
		# Checks if there is an author name provided
		if [ -n "$3" ]
		then
			# Sets authorname to be the third argument
			authorname="$3"
		else
			read -p "Enter author name: " authorname
		fi

		# Awk sentence that redirects all matching entries to a tempfile based on the author name
		awk -v RS="\n\n~~~~~~\n" -v author="$authorname" '/^Author: / tolower($0) ~ tolower(author) { print $0 "\n\n~~~~~~" }' "$logfile" >> tmpfile
		
		# If there is content in the tempfile, print and remove files
		if [ -s "tmpfile" ]
		then
			cat tmpfile
			rm tmpfile
			exit 0
		else
			# If there are no entries matching the author, exit
			echo -e "No entries found matching the author name '$authorname'."
			exit 1
		fi
	else
		# If there are no secondary flags
		# Prints out the content of the entire logfile in the terminal
		cat "$logfile"
		exit 0
	fi

# SHORT MESSAGE FLAG
elif [ "$1" = "--msg" -o "$1" = "-m" ]
then	
	# Removes backup if there is one from previously deleting last entry
	# THIS CAN BE REMOVED WHEN BACKUP IS MOVED TO .plog FOLDER AFTER INSTALL
	rm -f "$logfile".backup.log
	
	# Checks if the message is empty or not present
	if [ -z "$2" ] || [ "$2" = "" ]
	then
		echo "Error: Message cannot be empty"
		exit 1 	
	elif [ -n "$3" ]
	# Checks if there are a third argument, suggesting that the message is not in quotes
	then
		#NOTE: Double quotes or escaped quotes within the message may cause problems
		echo "Error: Message should be enclosed in single or double quotes"
		exit 1
	fi

	entry="$2"	
else
	# NO FLAGS

	# Checks if there are no flags provided to ensure positional arguments
	if [ ! -z "$2" ]
	then
		echo "Error: Flag arguments are positional and must be the first argument"
		exit 1
	fi

	# No flags detected
	# Removes backup if there is one from previously deleting last entry
	# THIS CAN BE REMOVED WHEN BACKUP IS MOVED TO .plog FOLDER AFTER INSTALL
	rm -f "$logfile".backup.log

	# Creates a temporary file for log entry
	tmpfile=$(mktemp)

	# Opens default text editor
	"$text_editor" "$tmpfile"
	
	# Checks if the file size is greater than zero
	if [ -s "$tmpfile" ]
	then
		# Reads content of temporary file to variable
		entry=$(cat "$tmpfile")
	else
		# Error when file is less than zero
		echo -e "\nError: Message is empty. No entry added"
		exit 1
	fi

	# Removes the temporary file
	rm "$tmpfile"
fi

# ADD ENTRY TO LOG FILE

# Display the current date using the RFC-3339 format (`YYYY-MM-DD hh:mm:ss TZ`)
timestamp=$(date --rfc-3339=s)

# Redirects the log entry to the log file
echo -e "\nEntry #$entry_number\n$timestamp\nAuthor: $author\n\n$entry\n\n~~~~~~" >> "$logfile"
echo -e "\nEntry #$entry_number added to ${logfile}"
