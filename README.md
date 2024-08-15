# timepatrol

## BTRFS snapshot manager and rollback tool 

![Alt text](/media/0.png?raw=true "Timepatrol in action!")


Timepatrol is a BTRFS snapshot manager and a rollback tool in a single script.
There are great tools out there which do the same, like Timeshift and Snapper,
for example, but I still prefer Timepatrol because:

* Easy to rollback to any snapshot.
* Minimal dependency: `ruby`.
* Outputs fit in half screen. Perfect for window manager users. 
* It has colors! Although it can be disabled.

In fact, it was written based on my personal needs but it may 
be of interest of a few people also. 

In principle it can be used in any Linux distribution. Arch users
will benefit from the `pacman` pre and post hooks which I found to be
very handy in the day-to-day use.

## Disclaimer

This is an early, experimental project. DO NOT use in a
production environment!

## Dependency
* `ruby`

## Installation

1. Clone the repo: `git clone https://github.com/abdeoliveira/timepatrol`
2. Enter the cloned folder: `cd timepatrol`
3. Make the `install.sh` script executable and run it: `chmod +x install.sh && sudo ./install.sh`. 

*Note:* If `pacman` is found, pacman hooks and 
the auxiliary script `timepatrol-pacman` will be installed.

## Uninstall

* Run the `uninstall.sh` script: `chmod +x uninstall.sh && sudo ./uninstall.sh`


## Configuration 
Adjust the `/etc/timepatrol/config` file as per your system. Check the comments in file for directions.

**A note regarding `/etc/fstab`**: The default installation in some distributions 
(Arch for instance) include the `subvolid` information in `fstab` for mounting 
points. Since rollbacks change such a number I recommend you omit the `subvolid` 
in the `/` entry. Mine reads as follows:

```
# Static information about the filesystems.
# See fstab(5) for details.

# <file system> <dir> <type> <options> <dump> <pass>
# /dev/mapper/ainstnvme0n1p2
UUID=054b4420-a2e0-41b1-8d66-8cc7198d8b55	/         	btrfs     	rw,relatime,ssd,space_cache=v2,subvol=/@	0 0

# /dev/mapper/ainstnvme0n1p2
UUID=054b4420-a2e0-41b1-8d66-8cc7198d8b55	/home     	btrfs     	rw,relatime,ssd,space_cache=v2,subvolid=257,subvol=/@home	0 0

# /dev/mapper/ainstnvme0n1p2
UUID=054b4420-a2e0-41b1-8d66-8cc7198d8b55	/var/log  	btrfs     	rw,relatime,ssd,space_cache=v2,subvolid=258,subvol=/@log	0 0

...
```

## Usage

Type `sudo timepatrol help` for a basic list of commands. They are

* `list`: lists snapshots limiting shown comments to 150 characters.

* `list-verbose`: lists snapshots without limit to comment characters.

* `list-grep 'STRING'`: lists snapshots containning `STRING` in comments. 

* `snapshot 'OPTIONAL COMMENT'`: takes a snapshot of `/` with (optional) 
given comment.

* `snapshot-keep 'OPTIONAL COMMENT'`: same as above plus it adds a protection against 
automatic deletion. Automatic deletion is set via the `MAXIMUM_SNAPSHOTS` 
variable in the `/etc/timepatrol/config` file. 
Protected snapshots are listed with `ID` in green color
and have a `*` mark, and
they do not count against the `MAXIMUM_SNAPSHOTS` variable.
For example, if 2 snapshots are protected and `MAXIMUM_SNAPSHOTS = 20`,
then the maximum number of snapshots will be 22. 

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
were selected for deletion. I recommend you play with the other selectors. In 
any case, the user will always be prompted to confirm the deletion 
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

(iii) Reboot immediately after kernel upgrade. To be on the safe side, 
reboot immediately after **any** system upgrade. See the `Troubleshooting`
section also.

## Bash completion

Copy and paste the following line to your `~/.bashrc`:

```
complete -W 'snapshot snapshot-keep toggle-keep delete rollback list list-verbose list-grep help' timepatrol
```

## Periodic, automatic snapshots

The simplest way is probably setting a cronjob as root. 

First, install `cronie`, then enable its service (something like 
`systemctl enable --now cronie.service`). Finnaly edit the crontab
with `sudo crontab -e`. If you for example want a hourly system snapshot, 
use something like 

```
0 * * * * /usr/local/bin/timepatrol snapshot 'hourly snapshot' >> /tmp/timepatrol.log 2>&1
```


and keep an eye on the file `/tmp/timepatrol.log` for eventual errors (hope not!).


## Changing a snapshot comment

Snapshots are kept in the `SNAPSHOTS_FOLDER` provided by the user in 
the `/etc/timepatrol/config` file. 

Each snapshot is composed by a folder, having the general structure as

```
SNAPSHOT_FOLDER/ID/data
```

and an information file, which is

```
SNAPSHOT_FOLDER/ID/info
```

The information file is a text file, 
structured with positional strings separated by `;`, as 
follows

```
date;time;comment;kernel;integer_variable
```

* `date` has format `yyyy.mm.dd`

* `time` has format `hh:mm:ss`

* `comment` is either empty or a string. It accepts spaces and most characters, but `;`.

* `kernel` is exaclty as given by `uname -r`

* `integer_variable` is `0` or `1`. The former meaning the snapshot is unprotected 
against automatic prunning, while the latter is the opposite. 


Now if you want to edit any information regarding any snapshot (most probably the
comment), it is just a matter of `vim` or `nano` its correspondent `info` file.


## Troubleshooting

### Unbootable system after rollback

Many factors can lead to an unbootable system after rollback.
For example, you may have upgraded the kernel, didn't reboot
and rollback. 

I have no sufficient
knowledge to cover all system-rescue situations, but I would say that
the following steps would fit in most cases:

1. Boot using a live media
2. Chroot into your (broken) system
3. Mount all partitions (eg. `mount -a`)
4. Reinstall your boot loader. Alterativelly, 
you can try to downgrade the kernel. If you are on Arch, try this second route 
since `pacman` is very good on setting things up. 
5. Exit chroot. Reboot.
