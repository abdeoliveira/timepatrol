#!/bin/bash
PATH_LIBALPM=/usr/share/libalpm
chmod +x timepatrol-pre
chmod +x timepatrol
cp 05-timepatrol-pre.hook $PATH_LIBALPM/hooks
cp timepatrol-pre $PATH_LIBALPM/scripts
cp timepatrol /usr/local/bin/
cp config /etc/timepatrol/
