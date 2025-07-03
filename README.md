# timepatrol

## BTRFS snapshots manager and rollback tool 

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

## Dependency
* `ruby`

## Installation

### Arch

From [AUR](https://aur.archlinux.org/packages/timepatrol-git), which I maintain myself.

### Other Linux
1. `git clone https://github.com/abdeoliveira/timepatrol`
2. `cd timepatrol`
3. `sudo ./install.sh` 

## Uninstall

### Arch

`sudo pacman -Rs timepatrol-git`

### Other Linux

`sudo rm -r /usr/bin/timepatrol /etc/timepatrol`

## Configuration 
Copy the example configuration file as

```
sudo cp /etc/timepatrol/config-example /etc/timepatrol/config
```

Then, check the comments in `config` file 
for directions and adjust it as per your system. 

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

* `list`: lists snapshots limiting shown comment characters.

* `list-verbose`: lists snapshots without limiting comment characters.

* `list-grep 'STRING'`: lists snapshots containning `STRING` in comments. 

* `snapshot 'OPTIONAL COMMENT'`: takes a snapshot of `/` with (optional) 
given comment.

* `snapshot-keep 'OPTIONAL COMMENT'`: same as above plus it adds a protection against 
automatic deletion. Automatic deletion is set via the `MAXIMUM_SNAPSHOTS` 
variable in the `/etc/timepatrol/config` file. 
Protected snapshots have a `*` mark next to their IDs, and
they do not count against the `MAXIMUM_SNAPSHOTS` variable.
For example, if 2 snapshots are protected and `MAXIMUM_SNAPSHOTS = 20`,
then the maximum number of snapshots will be 22. 

* `change-comment ID 'NEW COMMENT'`: replaces current COMMENT of snapshot ID by
'NEW COMMENT'.

* `delete`: deletes a snapshot. It accepts individual `ID` numbers and ranges. 
For example: `sudo timepatrol delete 1,10,20-23` will delete snapshots whose 
`ID`s are 1, 10, 20, 21, 22, and 23. The `delete` command also accepts 
the following substring selectors: `date=`, `time=`, `kernel=`, and `comment=`.
See the example of usage below:

```
oliveira@arch:~$ sudo timepatrol delete time=16:
*[208]  2024.08.12  16:30:05  6.10.4-arch2-1  Niri OK 
 [258]  2024.08.20  16:07:01  6.10.5-arch1-1  PRE: install libxp (1.0.4-3) 
 [259]  2024.08.20  16:07:56  6.10.5-arch1-1  PRE: remove libxp (1.0.4-3) 
 [260]  2024.08.20  16:26:31  6.10.5-arch1-1  PRE: install libxp (1.0.4-3), install 
                                              openmotif (2.3.8-3), install t1lib 
                                              (5.1.2-8) 
 [264]  2024.08.21  10:16:52  6.10.6-arch1-1  PRE: upgrade timepatrol-git 
                                              (r149.7e4bff6-1 -> r151.3f4f304-1) 
:: Confirm deletion of the selected snapshot(s) above? [y/N]
```

Note that all snapshots containing the user-given substring `16:` in the `time` field 
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

### Arch
1. Install `bash-completion`

2. Logout and login, or reboot.


### Other Linux
1. Install `bash-completion` 

2. Copy and paste the contents of 
`completions/timepatrol` to your `~/.bashrc`:

```
cat completions/timepatrol >> ~/.bashrc
```

3. Logout and login, or reboot.

## Periodic, automatic snapshots

For a 24/7 running machine, probably the simplest way is setting a cronjob as root. 

For notebooks, I recommend [simplecron](https://github.com/abdeoliveira/simplecron),
which I mantain myself.

## Troubleshooting

### Unbootable system after rollback

Several factors can lead to an unbootable system after a rollback. For instance, if you upgraded the kernel but didn't reboot before rolling back, your system might fail to start.

While I can't cover every possible system recovery scenario, the following steps should help in many cases:

1. Boot from a live media.
2. Chroot into your (broken) system.
3. Mount all partitions (e.g., `mount -a`).
4. Regenerate the initramfs (`mkinitcpio -P` for Arch, or the equivalent for your distro).
5. If the issue persists, try downgrading the kernel. On Arch, pacman generally handles this well.
6. Exit chroot and reboot.
