#!/bin/bash
PATH_LIBALPM=/usr/share/libalpm
CONFIG_DIR=/etc/timepatrol


## UNINSTALLS ALL SCRIPTS, THE WHOLE CONFIG FOLDER AND
## PACMAN HOOKS IF EXIST.


rm -f /usr/local/bin/timepatrol
rm -f $PATH_LIBALPM/scripts/timepatrol-*
rm -f $PATH_LIBALPM/hooks/*-timepatrol-*.hook
rm -r -f $CONFIG_DIR
