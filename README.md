# timepatrol
## BTRFS snapshot manager and rollback tool 

## Dependencies
* `ruby`
* `gem colorize` (installed as root, **not** `--user-install`) 

## Installation

### Arch and Arch-based

First check the `arch-install.sh` 
script. Then run `sudo ./arch-install.sh` if you are OK with it. Note it will install the `pacman` hook which is optional.

### Other distros

Make the `timepatrol` script executable and then copy it to a suitable path.

## Configuration 
Copy the `config` example to `/etc/timepatrol/` and adjust it as per your system.

For the subvolumes layout I recommend **against** using `@` for root and `@something` for the rest since the script needs to grep the root subvolume for rollbacks. Apart from that you can use virtually anything for naming and layout.

A note regarding `/etc/fstab`: The default installation in some distributions (Arch for instance) include the `subvolid` information in `fstab` for mounting points, including the `/` partition. Rollbacks change such a number so I recommend you omit the `subvolid` input from `fstab` at leats in the `/` line. Mine reads as follows:

```
# Static information about the filesystems.
# See fstab(5) for details.

# <file system> <dir> <type> <options> <dump> <pass>
# /dev/mapper/ainstnvme0n1p2
UUID=054b4420-a2e0-41b1-8d66-8cc7198d8b55	/         	btrfs     	rw,relatime,ssd,space_cache=v2,subvol=/@root	0 0

# /dev/mapper/ainstnvme0n1p2
UUID=054b4420-a2e0-41b1-8d66-8cc7198d8b55	/home     	btrfs     	rw,relatime,ssd,space_cache=v2,subvolid=257,subvol=/@home	0 0

# /dev/mapper/ainstnvme0n1p2
UUID=054b4420-a2e0-41b1-8d66-8cc7198d8b55	/var/log  	btrfs     	rw,relatime,ssd,space_cache=v2,subvolid=258,subvol=/@log	0 0

...
```


## Troubleshooting

### Locked pacman database after rollback
If you are on an Arch-based distro and you are using the pre-hook and have performed 
a rollback, you may endup with a locked pacman data base. Pacman will complain 
it can not lock data base before any transaction. To resolve this first
check if there is any process using it: `fuser /var/lib/pacman/db.lck`. 
If not, you can safely remove the lock: `rm /var/lib/pacman/db.lck`.


