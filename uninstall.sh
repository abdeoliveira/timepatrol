#!/bin/bash
PATH_LIBALPM=/usr/share/libalpm
CONFIG_DIR=/etc/timepatrol


## UNINSTALLS ALL SCRIPTS AND PACMAN HOOKS IF EXIST.

# CHECK IF RUNNING AS ROOT. ABORT IF FAILS.
if [ "$EUID" -ne 0 ]; then 
	echo "Please run as 'root'. ABORTED."
  exit 1
fi


rm -f /usr/local/bin/timepatrol
rm -f $PATH_LIBALPM/scripts/timepatrol-*
rm -f $PATH_LIBALPM/hooks/*-timepatrol-*.hook
#rm -r -f $CONFIG_DIR

echo "SUCCESS."
echo ""
echo "The '$CONFIG_DIR' configuration folder wasn't removed." 
echo "You may want to manually remove it by doing 'rm -r $CONFIG_DIR'."
