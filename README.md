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

## Usage

Type `sudo timepatrol help` for a basic list of commands. They are

* `list`: lists your snapshots.

* `snapshot 'OPTIONAL COMMENT'`: takes a snapshot of `/` with (optional) given comment.

* `snapshot-keep 'OPTIONAL COMMENT'`: same as above plus it adds a protection against 
automatice deletion. Automatic deletion is set via the `MAXIMUM_SNAPSHOTS` 
variable in the `/etc/timepatrol/config` file. 
Protected snapshots have a green mark close to their `ID` when `list`ed.
Protected snapshots will not count against the `MAXIMUM_SNAPSHOTS` variable.

* `delete`: deletes a snapshot. It accepts individual `ID` numbers and ranges. 
For example: `sudo timepatrol delete 1,10,20-23` will delete snapshots whose 
`ID`s are 1, 10, 20, 21, 22, and 23. The `delete` command also accepts 
the following substring selectors: `date=`, `time=`, `kernel=`, and `comment=`.
See the example of usage below:

First, `list`:
```
oliveira@arch:~$ sudo timepatrol list 
====================================================================================
                             :: TIMEPATROL SNAPSHOTS ::
====================================================================================
   ID   DATE        TIME      KERNEL         COMMENT
   [1]  2024.06.11  09:57:31  6.9.3-arch1-1  System OK 
   [4]  2024.06.11  10:01:05  6.9.3-arch1-1  pre: rollback to [2024.06.11 09:59:18] 
   [5]  2024.06.11  10:07:15  6.9.3-arch1-1  pre: Running 'pacman --upgrade 
                                             --noconfirm -- /home/oliveira/
                                             .cache/paru/clone/qtgrace/
                                             qtgrace-0.2.7-1-x86_64.pkg.tar.zst' 
   [7]  2024.06.11  10:09:17  6.9.3-arch1-1  pre: rollback to [2024.06.11 10:08:19] 
   [8]  2024.06.11  10:15:36  6.9.3-arch1-1  pre: Running 'pacman -Rs qtgrace' 
   [9]  2024.06.11  13:20:00  6.9.3-arch1-1  automatic 
 *[10]  2024.06.11  14:09:55  6.9.3-arch1-1  pre: starting full system upgrade. 
                                             Upgraded Hyprland to 0.41.0 
  [11]  2024.06.11  21:11:12  6.9.3-arch1-1  pre: Running 'pacman -S peek' 
  [12]  2024.06.11  21:12:47  6.9.3-arch1-1  pre: Running 'pacman -S mplayer' 
  [13]  2024.06.11  21:15:36  6.9.3-arch1-1  pre: Running 'pacman -Rs peek' 
  [14]  2024.06.11  21:17:54  6.9.3-arch1-1  pre: Running 'pacman -S wf-recorder' 
  [15]  2024.06.12  07:30:30  6.9.3-arch1-1  automatic 
  [16]  2024.06.12  07:39:06  6.9.3-arch1-1  pre: starting full system upgrade 
------------------------------------------------------------------------------------
TOTAL: 13
```

Then, let's delete something:

```
oliveira@arch:~$ sudo timepatrol delete time=10:
   [4] 2024.06.11 10:01:05 6.9.3-arch1-1 pre: rollback to [2024.06.11 09:59:18] 
   [5] 2024.06.11 10:07:15 6.9.3-arch1-1 pre: Running 'pacman --upgrade 
                                             --noconfirm -- /home/oliveira/
                                             .cache/paru/clone/qtgrace/
                                             qtgrace-0.2.7-1-x86_64.pkg.tar.zst' 
   [7] 2024.06.11 10:09:17 6.9.3-arch1-1 pre: rollback to [2024.06.11 10:08:19] 
   [8] 2024.06.11 10:15:36 6.9.3-arch1-1 pre: Running 'pacman -Rs qtgrace' 
:: Confirm deletion of the selected snapshot(s) above? [y/N]
```

Note that all snapshots containing the user-given substring `10:` in the `time` field 
were selected for deletion. I recommend you play with the other selectors. I
n any case, the user will always be prompted to confirm the deletion 
with the `No` answer being the defaut.

* `toggle-keep`: Toggles between protect and unprotect snapshots. 
It accepts an individul `ID`, list of `ID`s, ranges and selectors similar to the 
`delete` command above.

* `rollback`: rolls back the installation to a previous, selected snapshot state. 
Some notes: 

(i) rolling back to a snapshot whose kernel is different from the 
running kernel is not allowed (the script will ABORT). 
You must adjust the current kernel (downgrade/upgrade), then 
reboot (so it is loaded), then try to rollback. 

(ii) Plese read the recommendation regarding the `/etc/fstab` file before rollback. 

(iii) If you are on Arch and uses the shipped pacman pre-hook, 
read the `Troubleshooting` section.

## Bash completion

Copy and paste the following line to your `~/.bashrc`:

```
complete -W 'snapshot snapshot-keep toggle-keep delete rollback list help' timepatrol
```

## Troubleshooting

### Locked pacman database after rollback
If you are on an Arch-based distro and you are using the pre-hook and have performed 
a rollback, you may endup with a locked pacman data base. Pacman will complain 
it can not lock data base before any transaction. To resolve this first
check if there is any process using it: `fuser /var/lib/pacman/db.lck`. 
If not, you can safely remove the lock: `rm /var/lib/pacman/db.lck`.


