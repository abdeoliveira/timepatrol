#!/bin/bash
set -e

PATH_LIBALPM=/usr/share/libalpm
CONFIG_DIR=/etc/timepatrol
SRC_DIR=/usr/bin
CONFIG_FILE=$CONFIG_DIR/config


# CHECK IF RUNNING AS ROOT. ABORT IF FAILS.
if [ "$EUID" -ne 0 ]; then 
	echo "Run as 'root'. ABORTED."
  exit 1
fi


# CHECK FOR INSTALLED RUBY. ABORT IF FAILS.
if ! command -v ruby &> /dev/null; then
	echo "'ruby' not found. ABORTED."
	exit 1
else
	echo "* Found '$(command -v ruby)'. Proceeding."
fi


# CHECK FOR BTRFS EXECUTABLE. ABORT IF FAILS.
if ! command -v btrfs &> /dev/null; then
	echo "'btrfs' not found. ABORTED"
	exit 1
else
	echo "* Found '$(command -v btrfs)'. Proceeding."
fi


## INSTALLS THE 'CONFIG' FILE. SKIP IF IT ALREADY EXISTS.
if test -f $CONFIG_FILE; then
	echo "* Found '$CONFIG_FILE'. Skipping 'config' installation."
else
	install -Dm 644 config -t $CONFIG_DIR/
	echo "* Installed 'config' file at '$CONFIG_DIR'."
fi



# INSTALLS TIMEPATROL.
install -Dm 755 timepatrol -t $SRC_DIR/
echo "* Installed 'timepatrol' at '$SRC_DIR'."


## INSTALL HOOKS IF PACMAN IS FOUND.
if command -v pacman &> /dev/null; then
	install -Dm 755 timepatrol-pacman -t $PATH_LIBALPM/scripts/
	install -Dm 644 05-timepatrol-pre.hook -t $PATH_LIBALPM/hooks/
	install -Dm 644 zz-timepatrol-post.hook -t $PATH_LIBALPM/hooks/
	echo "* Found 'pacman':  * installed hooks at '$PATH_LIBALPM/hooks'."
	echo "                   * installed auxiliary script 'timepatrol-pacman' at"
	echo "                     '$PATH_LIBALPM/scripts'."
fi

echo "SUCCESS!"
