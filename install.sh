#!/bin/bash
set -e

PATH_LIBALPM=/usr/share/libalpm
CONFIG_DIR=/etc/timepatrol
CONFIG_FILE=$CONFIG_DIR/config


# CHECK IF RUNNING AS ROOT. ABORT IF FAILS.
if [ "$EUID" -ne 0 ]; then 
	echo "Please run as 'root'. ABORTED."
  exit 1
fi


# CHECK FOR INSTALLED RUBY. ABORT IF FAILS.
if ! command -v ruby &> /dev/null; then
	echo "'ruby' not found. ABORTED."
	exit 1
else
	echo "* Found '$(command -v ruby)'. Proceeding."
fi


# CHECK FOR ROOT GEM COLORIZE. ABORT IF FAILS.
if ! gem list -i "^colorize$" &> /dev/null; then
	echo "* Could not find 'gem colorize' for root. ABORTED"
	echo "SUGGESTION: run 'gem install colorize' as ROOT."
	exit 1
else
	echo "* Found root gem colorize. Proceeding."
fi	


## INSTALLS THE 'CONFIG' FILE. SKIP IF IT ALREADY EXISTS.
mkdir -p $CONFIG_DIR
if test -f $CONFIG_FILE; then
	echo "* Found '$CONFIG_FILE'. Skipping 'config' installation."
else
	cp config $CONFIG_DIR
	echo "* Installed 'config' file at '/etc/timepatrol'."
fi



# INSTALLS THE TIMEPATROL SCRIPT.
chmod +x timepatrol
cp timepatrol /usr/local/bin/
echo "* Installed 'timepatrol' at '/usr/local/bin'."


## INSTALLS HOOKS IF PACMAN IS FOUND.
if command -v pacman &> /dev/null; then
	chmod +x timepatrol-pacman
	cp timepatrol-pacman $PATH_LIBALPM/scripts/
	cp 05-timepatrol-pre.hook $PATH_LIBALPM/hooks/
	cp zz-timepatrol-post.hook $PATH_LIBALPM/hooks/
	echo "* Found 'pacman':"
	echo "                  --> installed hooks at '$PATH_LIBALPM/hooks'."
	echo "                  --> installed auxiliary script 'timepatrol-pacman' at"
	echo "                      '$PATH_LIBALPM/scripts'."
fi

echo "SUCCESS!"
