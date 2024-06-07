# snapxi

Script to manipulate BTRFS snapshots optimized for Void's xbps package manager. 

# Dependency

- `ruby`

# Configuration

`snapxi` expects a few things to work properly which shall be defined
in the code itself (first few lines). My sugestion is:

1. `@rootvol = @root`, where `@root` is the subvolume to be mounted to `/`

2. `@snapvol = @snapshots`, where `@snapshots` is the subvolume to be mounted to 
`@snapdir = /.snapshots`. 

3. `@device = /dev/sd<x>` is your device. Note that `@device` is NOT a subvolume.
The symbol `@` used here is part of Ruby's syntax for a certain kind of variable definition.

4. Yet, both `@root` and `@snapshots` subvolumes (following my suggestion but you
may give any names you want) must lie in the same partition.
This is important for rollbacks only and `snapxi` will check such a requirement
giving the following fail message if not met: `Mounting stage went wrong. ABORTED.`

## Note on encrypted devices

For the aforementioned `@device` you need to use `/dev/mapper/<something>` instead of the usual `/dev/sd<X>`. 
A good test to check if your system meets `snapxi` requirements is to mount your `@device` to `/mnt`, like: `sudo mount /dev/mapper/crypto-luks /mnt`. After successful mount, you must see the `@root` and  `@snapshots` subvolumes in `/mnt`. 
After such a test, you can safely unmount `/mnt` just doing `sudo umount /mnt`


# Installation

1. Copy the snapxi script to your `PATH`.

2. Make it executable.

# Manual

Run `sudo snapxi help` for commands. 

Also check the small tutorial on [YouTube](https://youtu.be/pP1XR38-FBE).


# Troubleshooting

# Known Bugs 

