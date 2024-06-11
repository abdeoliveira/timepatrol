# timepatrol
## BTRFS snapshot manager and rollback tool 

## Dependencies
* ruby
* gem 'colorize' (install with sudo, not --user-install) 

## Installation
If you are on Arch or Arch-based distribution, first check the `install.sh` 
script. Then run `sudo ./install.sh` if you are OK with it. Note it will install `pacman` hooks which are optional.

If not, just `cp` the `timepatrol` script to a suitable path.

## Configuration 
Copy the `config` example to `/etc/timepatrol/`.

## Troubleshooting

### Locked pacman database after rollback
If you are on an Arch-based distro 
and are using the pre-hook and have performed a rollback,
you likely ends up with a locked pacman data base. Pacman will complain 
it can not lock data base before any transaction. To resolve this first
check if there is any process using it: `fuser /var/lib/pacman/db.lck`. 
If not, you can safely remove the lock: `rm /var/lib/pacman/db.lck`.


