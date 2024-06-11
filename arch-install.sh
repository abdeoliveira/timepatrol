#!/bin/bash
PATH_LIBALPM=/usr/share/libalpm
CONFIG_DIR=/etc/timepatrol

chmod +x timepatrol-pre
chmod +x timepatrol

cp 05-timepatrol-pre.hook $PATH_LIBALPM/hooks/
cp timepatrol-pre $PATH_LIBALPM/scripts/
cp timepatrol /usr/local/bin/

mkdir -p $CONFIG_DIR
cp config /etc/timepatrol/
