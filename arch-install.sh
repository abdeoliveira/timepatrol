#!/bin/bash
PATH_LIBALPM=/usr/share/libalpm
CONFIG_DIR=/etc/timepatrol

## INSTALLS THE SCRIPT AND CONFIG FILE 
chmod +x timepatrol
cp timepatrol /usr/local/bin/
mkdir -p $CONFIG_DIR
cp config $CONFIG_DIR

## COMMENT IF YOU DON'T WANT THE PACMAN HOOKS.
chmod +x timepatrol-pacman
rm $PATH_LIBALPM/scripts/timepatrol-*
cp timepatrol-pacman $PATH_LIBALPM/scripts/
rm $PATH_LIBALPM/hooks/*-timepatrol-*.hook
cp 05-timepatrol-pre.hook $PATH_LIBALPM/hooks/
cp zz-timepatrol-post.hook $PATH_LIBALPM/hooks/

