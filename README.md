
<img align="right" height="256" src="./plog.png">

# plog
    
plog is a command line tool for creating project logs and entries from CLI. Keep track of projects (or anything) by having simple log files. Perfect for large school projects that require progress documentation. Written in Bash.

## Install
I am going to create an install script and have the main script as a binary file that gets copied into /bin and a .folder for settings/configs and stuff. The goal is to be able to just write "plog" in terminal. I will get to this at a later date.

**For now, just run plog.sh in terminal**

***

Make sure the script have execution rights by running chmod:

`chmod 777 plog.sh`

plog will create a log file in the current directory. For help menu run

`./plog.sh --help`

**Note:**

Since I haven't created an install yet, make sure to move help.txt and .config to the folder you are running plog.sh from if you want to create logs in another directory than the one you install. The script works just fine without help.txt, but you wont be able to invoke --help without it. The .config file however, *must* be in the same folder as plog.sh

## How to use
Invoke plog with ./plog.sh. *Usage:* ./plog.sh [option]. 

By invoking without any options, a nano text editor will open for longer log entries.

The first time you run the program it will check if there is a log file present in the current directory. If not, you are prompted for a file name which creates the file. 

**Note:** There can only be *one* log file in the current directory for the program to work. Except for a backup file when creating a backup of the log file.

The log format is as following:

```
[Initial meta text for the document]

<Timestamp>
<Author>

<Entry>

~~~~~~
```
___

**Options:**
| Short option | Long option | Description                                                                                                                                                                   |
| ------------ | --------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
|              |             | No options opens a nano text editor for longer text entries. Ctrl+S Ctrl+X to save and quit after writing an entry. Default text editor can be changed in the .config file.   |
| \-h          | \--help     |  Display help message (help.txt must be in the same directory as plog.sh)                                                                                                     |
| \-m          | \--msg      | Write a short message without entering nano. The text must be in single or double quotes.                                                                                     |
| \-dl         | \--dlast    | Delete last entry. Creates a backup file which will be deleted at next entry (the deletion is a temporary solution and won't be that way when the install script is in place) |
| \-r          | \--revert   | Revert log file to backup                                                                                                                                                     |
| \-a          | \--author   | Sets author in settings. Default is the whoami command which provides the username for your user name on your computer.                                                       |

___
### Settings

You can change some settings in the .config file:

**Author:** Can be changed by invoking plog.sh -a or by manually entering it in the .config file. The author name will be displayed in each log entry. The default is whoami.

**Editor delay:** There is a delay of 1.5 seconds in place before opening the nano text editor. This is so the user have time to read the instruction for nano before entering it. If you want less or more delay you can change it.

**Default text editor:** The default text editor is nano. You can however change it to your prefered text editor. There are some common options commented out that you can choose from, or you can write in your own.

**Default time format:** Each log entry has a time stamp. If you want to change from the default dd:mm:yyyy hh:mm:ss format you can use some of the provided examples which is commented out, or you can set your own prefered format.

## License and attributions
This project is licensed with GNU GENERAL PUBLIC LICENSE V3

[Tractor icons created by Futuer - Flaticon](https://www.flaticon.com/free-icons/tractor)

plog is made by jrgn

## Roadmap

✅ Create a basic working prototype

❌ Pre-alpha test prototype with all functionality

❌ Create an install script and binary file

❌ Alpha test with program installer

❌ Open beta test

❌ Release for Linux

❌ MacOS compatible version

❌ WSL compatible version

❌ Powershell script version for Windows (if I bother...)