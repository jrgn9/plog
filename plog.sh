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

# Function to extract entries from the log file based on a cutoff (date/ID) and position
extract_entries() {
	awk -v RS="\n\n~~~~~~\n" -v cutoff_start="$1" -v cutoff_end="$2" -v position="$3" '
		BEGIN {
			# If sentence to check if cutoff is date or id and sets it to 0 or 1
			is_id = (cutoff_start ~ /^[0-9]+$/) ? 1 : 0

			# Variable for flagging the first entry of cutoff_end
			start_passed = 0
			end_passed = 0
			match_start_passed = 0
			match_end_passed = 0
		}

		# Function to print the current entry followed by delimiter
		function print_entries() {
			print $0 "\n\n~~~~~~"
		}

		{
			# Extract the actual ID from the entry number in log entry
			if ($0 ~ /^\nEntry #[0-9]+/) {
				split($2, parts, "#")
				actual_id = parts[2]
			}

			
			# Match checks:

			# If cutoff is id set start and end to entry number less/more than and equal cutoff start/end
			if (is_id) {
				match_id_start = (actual_id >= cutoff_start)
				match_id_end = (actual_id <= cutoff_end)
			}
			# If cutoff is date set start and end to match the date of the record
			else {
				# Split the record into lines
				split($0, lines, "\n")

				# Match date to the entry timestamp (third line of each entry)
				match_date_start = (lines[3] ~ cutoff_start)
				match_date_end = (lines[3] ~ cutoff_end)
			}

			# Flag updates:
			
			# Checks if we passed the first match_start entry
			if (match_id_start || match_date_start) {
				start_passed = 1
			}
			# Checks if we passed all the match_start entries
			if (start_passed && (!match_id_start || !match_date_start)) {
				match_start_passed = 1
			}
			# Checks if we have reached the first entry of the cutoff_end
			if (match_id_end || match_date_end) {
				end_passed = 1
			}
			# Checks if we passed all match_end entries
			if (end_passed && !match_id_end && !match_date_end) {
				match_end_passed = 1
			}

			# Position checks:

			# If the position is before and the state is at the start print current entry
			if (position == "before" && !match_id_start && !match_date_start && !start_passed && !match_start_passed) {
				print_entries()
			}
			# If the position is between and we are passed match_start and until all of match_end, print current entry
			else if (position == "between" && start_passed && !match_end_passed) {
				print_entries()
			}
			# If position is after and we are passed the end match_end, print current entry
			else if (position == "after" && match_end_passed) {
				print_entries()
			}
		}
	' "$logfile"
}

## FLAG CHECKS

# DELETE ENTRY FLAG
if [ "$1" = "--delete" -o "$1" = "-d" ]
then
	# Creates a backup before deleting entries
	# IN THE BIN FILE SET THE PATH TO ~/.plog/backup.log
	cp "$logfile" "$logfile".backup.log

	# REMEMBER: CHANGE PATH AFTER INSTALLER!!!!!
	# Counts the length of the init message
	init_length=$(wc -l < init.txt)

	# Add 5 lines to account for log title and delimiters
	empty_length=$(($init_length + 5))

	# Checks if there are any entries (skipping the init message)
	if [[ $(awk "NR>$empty_length" "$logfile") == "" ]]
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
			# awk sentence to extract the last entry number
			last_entry_id=$(awk -F'#' '/^Entry #/ {id=$2} END {print id}' "$logfile")

			# Use extract_entries function to redirect everything but last entry to tmpfile and overwrite logfile
			extract_entries "$last_entry_id" "$last_entry_id" "before" > tmpfile
			mv tmpfile "$logfile"

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
				# Sets deleteid to be the provided number
				deleteid_start="$3"

				# if there is a fourth argument, sets deleteid_end to fourth argument, otherwise sets to deleteid_start
				if [ -n "$4" ]
				then
					deleteid_end="$4"
				else
					deleteid_end="$deleteid_start"
				fi
			else
				# Prompts the user for ids to delete
				echo "Delete by entry number"
				echo "Enter entry number to delete or two numbers seperated by space for deleting a range of entries (range inclusive)"
				read -p "Enter entry number(s) to delete: " deleteid_start deleteid_end

				# If no range is provided, sets deleteid_end to deleteid_start
				if [ -z "$deleteid_end" ]
				then
					deleteid_end="$deleteid_start"
				fi
			fi

			# Check if deleteid_start is empty
			if [ -z "$deleteid_start" ]
			then
				echo "No ID provided. Aborting delete operation."
				exit 1
			fi

			# Uses the extract_entries function to extract all the entries before and after the entries to delete
			extract_entries "$deleteid_start" "$deleteid_end" "before" > tmpfile
			extract_entries "$deleteid_start" "$deleteid_end" "after" >> tmpfile
			
			# Overwrites the extracted entries to the logfile
			mv tmpfile "$logfile"

			# Check if the file was modified and prints message accordingly
			if [[ $? -eq 0 ]]
			then
				
				echo "Entry number $deleteid_start to $deleteid_end deleted"
			else
				echo "Could not delete $deleteid_start to $deleteid_end"
			fi
		fi

		exit 0
	fi

# RESTORE TO BACKUP FLAG
elif [ "$1" = "--restore" -o "$1" = "-r" ]
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

	# Edit warning for the user (can be turned off in settings)
	if [ "$edit_warning" = "on" ]
	then
		echo "WARNING: Do not edit the log format, dates or separators!"
		echo "This can have unintended consequences! (this warning can be turned off in settings)"
		sleep 3
	fi

	# Edit arguments
	if [ "$2" = "date" ]
	then
		# Edit by date argument
		
		# Checks if there is a date provided as argument
		if [ -n "$3" ]
		then
			# Sets editdate to be third argument
			editdate_start="$3"
			if [ -n "$4" ]
			then
				# Sets editdate to be third argument
				editdate_end="$4"
			else
				editdate_end="$editdate_start"
			fi
		else
			# No third argument, prompts user for date
			echo "Edit by date"
			echo "Enter one date or two dates seperated by space for a date range (optional)"
			read -p "Enter date(s) in format YYYY-MM-DD: " editdate_start editdate_end

			if [ -z "$editdate_end" ]
			then
				editdate_end="$editdate_start"
			fi
		fi
		# Awk sentence that redirects all matching dates to a tempfile
		extract_entries "$editdate_start" "$editdate_end" "between" > tmpfile
		
		# Store the original content in a variable before editing
		original_entries=$(extract_entries "$editdate_start" "$editdate_end" "between")

	elif [ "$2" = "id"  -o "$2" = "ID" ]
	then
		# Edit by id argument

		# Checks if there is an id provided as argument
		if [ -n "$3" ]
		then
			# Sets editid to be third argument
			editid_start="$3"

			if [ -n "$4" ]
			then
				editid_end="$4"
			else
				editid_end="$editid_start"

			fi

		else
			# No third argument, prompts user for id
			echo "Edit by id"
			echo "Enter one entry number or two numbers seperated by space for id range (optional)"
			read -p "Enter entry number id: " editid_start editid_end

			if [ -z "$editid_end" ]
			then
				editid_end="$editid_start"
			fi
		fi

		# Awk sentence that redirects all matching ids to a tempfile
		extract_entries "$editid_start" "$editid_end" "between" > tmpfile

		# Store the original content in a variable before editing
		original_entries=$(extract_entries "$editid_start" "$editid_end" "between")

	elif [ "$2" = "last" ]
	then
		# Edit last entry
		echo "Edit last entry"

		# awk sentence to extract the last entry number
		last_entry_id=$(awk -F'#' '/^Entry #/ {id=$2} END {print id}' "$logfile")

		# Use extract_entries function to redirect the last entry to tmpfile
		extract_entries "$last_entry_id" "$last_entry_id" "between" > tmpfile

    	# Store the original content in a variable before editing
		original_entries=$(extract_entries "$last_entry_id" "$last_entry_id" "between")

	else
		# No arguments
		
		### Should i bother error handling???

		# Opens the log file with the default editor
		"$text_editor" "$logfile"

		### Check if there was any changes and print message accordingly

		exit 0
	fi

	# If there is content in the tempfile from date, id or last, open it in the editor
	if [ -s "tmpfile" ]
	then
		# Open temp file with matching entries in default text editor
		"$text_editor" "tmpfile"
    
		# Get the edited entries from the tmp file and adds in the delimiter
		edited_entries=$(cat "tmpfile")

		# Checks number of entries before and after editing
		num_entries_before=$(echo "$original_entries" | grep -o "~~~~~~" | wc -l)
		num_entries_after=$(echo "$edited_entries" | grep -o "~~~~~~" | wc -l)
		# FOR DEBUGGING:
		echo "entries before: $num_entries_before entries after: $num_entries_after"
		
		# Error handling in case user has edited dates or number of entries
		if [ "$num_entries_before" != "$num_entries_after" ]
		then
			echo "Warning: The number of log entries has been modified." 
			echo "This might be due to editing seperators or the format."
			echo "Before editing: $num_entries_before entries"
			echo "After editing: $num_entries_after entries"
			read -p "Are you sure you want to save your changes? (y/n): " error_answer
			edit_error=1
		fi

		# MIGHT ADD ERROR HANDLING FOR EDITING DATES AND ENTRY NUMBERS
		# SEE GIT COMMIT ab9489e69a12df3f16f38989b03b129f37aa5ef9

		# Continues to overwrite changes if there are no errors 
		# or the user wants to continue anyways
		if [ "$edit_error" != "1" ] || [ "$error_answer" = "y" ]
		then
			if [ -n "$editdate_start" ]
			then
				# Extract entries before the edit date and append them to tmpfile2
				extract_entries "$editdate_start" "$editdate_end" "before" > tmpfile2

				# Append the edited entries to tmpfile2
				echo "$edited_entries" >> tmpfile2

				# Extract entries after the edit date and append them to tmpfile2
				extract_entries "$editdate_start" "$editdate_end" "after" >> tmpfile2
			
			elif [ -n "$editid_start" ]
			then
				# Extract entries before the entry id and append them to tmpfile2
				extract_entries "$editid_start" "$editid_end" "before" > tmpfile2

				# Append the edited entries to tmpfile2
				echo "$edited_entries" >> tmpfile2

				# Extract entries after the entry id and append them to tmpfile2
				extract_entries "$editid_start" "$editid_end" "after" >> tmpfile2

			else
				# Edit last entry, since there are no editid or editdate

				# Extract all entries before the last and append them to tmpfile2
				extract_entries "$last_entry_id" "$last_entry_id" "before" > tmpfile2

				# Add the edited entry to tmpfile2
				echo "$edited_entries" >> tmpfile2
			fi

			# Moves tmpfile2 back to the log file, overwriting it
			mv tmpfile2 "$logfile"

			echo "Changes saved."

		else
			echo "No changes were saved."
		fi
		
	# Remove the temporary file
	rm tmpfile
else
	# If there are no entries found for the provided date, display a message		
	echo "No entries found for the provided search parameter. Check if you have used the correct date format or id number."
	rm tmpfile
	exit 1
fi

exit 0


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
			printdate_start="$3"

			# If there is a fourth argument, sets printdate_end to fourth argument
			if [ -n "$4" ]
			then
				printdate_end="$4"
			else
				# If there is no fourth argument, sets printdate_end to printdate_start
				printdate_end="$printdate_start"
			fi

		else
			# No third argument, prompts user for date
			echo "Enter one date or two dates seperated by space for a date range (optional)"
			read -p "Enter date(s) in format YYYY-MM-DD: " printdate_start printdate_end

			# If there is no end date set it to be the same as start
			if [ -z "$printdate_end" ]
			then
				printdate_end="$printdate_start"
			fi
		fi

		# Use the extract_entries function to redirect matching entries to a tmpfile
		extract_entries "$printdate_start" "$printdate_end" "between" > tmpfile

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
			# Sets printid_start to be the third argument
			printid_start="$3"

			# If there is a fourth argument, sets printid_end to fourth argument
			if [ -n "$4" ]
			then
				printid_end="$4"
			else
				# If there is no fourth argument, sets printid_end to printid_start
				printid_end="$printid_start"
			fi
		
		else
			# No third argument, prompts user for date
			echo "Enter one entry number or two numbers seperated by space for an id range (optional)"
			read -p "Enter entry number(s): " printid_start printid_end
			
			# If there is no end id set it to be the same as start
			if [ -z "$printid_end" ]
			then
				printid_end="$printid_start"
			fi

		fi

		# Use the extract_entries function to redirect matching entries to a tmpfile
		extract_entries "$printid_start" "$printid_end" "between" > tmpfile

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
