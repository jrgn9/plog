
<img align="right" height="256" src="./plog.png">

# plog
    
plog is a command line tool for creating project logs and entries from CLI. Keep track of projects by having simple log files. Perfect for large school projects that require progress documentation. Written in Bash.

## Install
I am going to create an install script and have the main script as a binary file that gets copied into /bin and maybe a .folder for settings/configs and stuff. The goal is to be able to just write "plog" in terminal. I will get to this at a later date.

**For now, just run plog.sh in terminal**

## How to use
Make sure the script have execution rights by running
```
chmod 777 plog.sh
```

plog will create a log file in the current directory. For help menu run
```
./plog.sh --help
```

Since I haven't created an install yet, make sure to move help.txt to the folder you are running plog.sh from if you want to be able to print the help screen. However, the script works just fine without help.txt, so you can move it to whichever folder you want to create a .log file in.

## License and attributions
This project is licensed with GNU GENERAL PUBLIC LICENSE V3

[Tractor icons created by Futuer - Flaticon](https://www.flaticon.com/free-icons/tractor)

plog is made by jrgn

## Roadmap and to-do

✅ Create a basic working prototype

❌ Pre-alpha test prototype with all functionality

❌ Create an install script and binary file

❌ Alpha test with program installer

❌ Open beta test

❌ Release for Linux

❌ MacOS compatible version

❌ WSL compatible version

❌ Powershell script version for Windows (if I bother...)