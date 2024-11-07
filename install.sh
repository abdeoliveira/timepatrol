#!/bin/bash
set -e

CONFIG_DIR=/etc/timepatrol
SRC_DIR=/usr/bin

# CHECK IF RUNNING AS ROOT. ABORT IF FAILS.
if [ "$EUID" -ne 0 ]; then 
	echo "Run as 'root'. ABORTED."
  exit 1
fi

# CHECK FOR BTRFS EXECUTABLE. ABORT IF FAILS.
if ! command -v btrfs &> /dev/null; then
	echo "'btrfs' not found. ABORTED"
	exit 1
else
	echo "* Found '$(command -v btrfs)'. Proceeding."
fi

# CHECK FOR INSTALLED RUBY. ABORT IF FAILS.
if ! command -v ruby &> /dev/null; then
	echo "'ruby' not found. ABORTED."
	exit 1
else
	echo "* Found '$(command -v ruby)'. Proceeding."
fi

# INSTALL TIMEPATROL.
install -Dm 755 timepatrol -t $SRC_DIR/
echo "* Installed 'timepatrol' at '$SRC_DIR'."

# INSTALL CONFIG FILE
install -Dm 644 config-example -t $CONFIG_DIR/
echo "* Installed the 'config-example' file at '$CONFIG_DIR'"
echo " "
echo ":: Now rename the 'config-example' file as '$CONFIG_DIR/config' and"
echo ":: edit it according to your system."
echo " "
echo "SUCCESS!"
