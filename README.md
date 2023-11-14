
<img align="right" height="256" src="./program_files/plog.png">

# plog
    
plog is a command line tool for creating project logs and entries from CLI. Keep track of projects (or anything) by having simple log files. Perfect for large school projects that require progress documentation. Written in Bash.

## 📥 Install
Download the latest version or use git to clone the repo. Make sure to give the install script execution rights:

`sudo chmod u+x install.sh`

Run the install script with sudo: 

`sudo ./install.sh`

The installer must be run with sudo so that the script have access to moving the binary file to /usr/local/bin and create a .plog folder. The script moves the programs binary file to /usr/local/bin so that the program can be executed from wherever. It creates a .plog folder in /home/$USER/ where all the program files are located. This is also the folder where backups will be saved.

## ⚡ Quick start

For help and list over all functionality:

`plog -h`

In the directory you want to create a log:

`plog`

Follow prompts to set file name and title and add first log entry. After saving you can print the log:

`plog -p`

To delete the last entry you made:

`plog -d last`

To restore the log to before the deletion:

`plog -r`

To edit program settings to remove edit/delete warning, author name or default text editor:

`plog --settings`

## 📝 How to use
**Usage:** `plog [option]`

By invoking without any options, the default text editor will open for longer log entries. The first time you run the program it will check if there is a log file present in the current directory. If not, you are prompted for a file name which creates the file. 

**Important:** There can only be *one* log file in the current directory for the program to work. Except for a backup file when creating a backup of the log file.

The log format is as following:

```
[Initial meta text for the document]

<LOG TITLE>

---START OF LOG---

<Timestamp YYYY-MM-DD hh:mm:ss TZ>
Author: <Author name>

<Entry>

~~~~~~
```
___

### 🧰 Options:

This is a list of options which can be used when invoking plog. When no option is given, the default editor will open for writing longer entries. The secondary options are optional, except for delete where you have to specify what to delete and -m where you need to write the entry in quotes. 
 
| Short option | Long option  | Secondary options        | Description                                                                                                                                                                              |
| ------------ | ------------ | ------------------------ | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
|              |              |                          | No options: Opens the default text editor for writing longer log entries                                                                                                                 |
| \-h          | \--help      |                          | Display help message                                                                                                                                                                     |
| \-m          | \--msg       | ** "entry text"            | Write short message without entering a text editor. Must be in "quotes"                                                                                                                  |
| \-d          | \--delete    |** last, id                 | Delete an entry. Creates a backup file which can be reverted. Use with 'last' or 'id' to delete based on those options. Provide two id numbers for deleting a range of entries.                                                                   |
| \-e          | \--edit      | last, id, date           | Opens the log file in your default text editor for editing. Opens the whole file if there are no second argument. Use 'last', 'id' or 'date' to edit entries based on those options. Provide two dates or id numbers for editing a range of entries.    |
| \-p          | \--print     | id, date, author, search | Prints log entries to terminal. Prints the whole file if no extra arguments are present. Use 'id', 'date', 'author' or 'search' to filter out entries. Provide two dates or id numbers for printing a range of entries.                                   |
| \-i          | \--import    | relative/path/to/file    | Imports the content of a file and adds it as a log entry. Uses relative path based on your current directory. Prompts you for file path if you haven't provided it as a second argument. |
| \-r          | \--restore    |                          | Restore log file back to before doing an edit/deletion. A backup is created after deleting or editing a file, in case of accidents.                                                       |
| \-a          | \--author    |                          | Set author name in config. Default is the computer user name. Write 'user' to revert back to default author name.                                                                        |
|              | \--settings  |                          | Opens the config file to change settings                                                                                                                                                 |
|              | \--init      |                          | Opens the initialization text in an editor, so you can edit the meta text which the file is initialized with                                                                             |
|              | \--about     |                          | Prints info about the program in the terminal                                                                                                                                            |
|              | \--uninstall |                          | Uninstall plog by running an uninstall script (log files are not affected)                                                                                                               |

** *Secondary option is required*

*Note: For date or id ranges (in print, edit or delete) you can write them directly as a third option or you will be prompted if you don't provide them directly. The ranges are inclusive.*

#### Examples:

**Print all entries made by jrgn in the terminal window:**

`plog -p author jrgn`

**Delete last entry:**

`plog -d last`

**Add a short entry:**

`plog -m "This is an entry"`

**Add fun.txt from the Downloads folder as an entry:**

`plog -i ../Downloads/fun.txt`

**Edit entry number 4 to 8 (inclusive)**

`plog -e id 4 8` 

**Edit all entries from 20. July 2023:**

`plog -e date 2023-07-20`

*(If you write plog -e id or date without a third argument you will be prompted for one or two entry id numbers/dates)*
___

### ⚙️ Settings

You can change some settings in the config file (manually or by running plog --settings)

**Author:** Can be changed by invoking plog.sh -a or by manually entering it in the config file. The author name will be displayed in each log entry. The default is your computer username (whoami).

**Default text editor:** The default text editor is nano. You can however change it to your prefered text editor. There are some common options commented out that you can choose from, or you can write in your own.

**Initialization text:** This text is the start of every log file. By default it will say that it is a log file created by plog, and a divider to show where the log file starts. This text can be edited by using the plog --init option.

**Edit warning/delete confirmation:** You can turn off edit warning which warns you that messing up the log structure and delimiters can have unintended consequences. The delete confirmation prompts you for a confirmation before you delete entries. If you don't want this you can turn one or both off.

*Might add: Settings for auto backup*

### 🚮 Uninstall

To uninstall run `plog --uninstall`. An uninstall script will run. All the program files will be deleted. You can choose if you want to keep your backups or want them removed. All .plog files will not be affected by the uninstallation (unless they are in the .plog folder in home directory).

## 🪪 License and attributions
This project is licensed with [GNU General Public License v3](https://www.gnu.org/licenses/gpl-3.0.en.html)

[Tractor icons created by Futuer - Flaticon](https://www.flaticon.com/free-icons/tractor)

plog is made by Jørgen Skontorp

## 🚧 Roadmap

✅ Create a basic working prototype

✅ Pre-alpha test prototype with all functionality

✅ Create an install script with binary file 

❌ Alpha test with program installer

❌ Add auto backup functionality

❌ Open beta test

❌ Release for Linux