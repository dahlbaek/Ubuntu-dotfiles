# config for my Debian setup

A collection of my dotfiles and other setup (mostly minor
tweaks to default configs) along with some simple setup
instructions for Debian Stretch.

## get git

Get git by running the command

```sh
sudo apt-get install git
```

## clone the repository

Further instructions and scripts assume that `git` has been used to clone the
repository to `~/git/dotfiles`

```sh
git clone https://github.com/dahlbaek/Ubuntu-dotfiles.git "${HOME}/git/dotfiles"
```

## iptables

Copy the `enable-firewall.sh` and `disable-firewall.sh` scripts to a secure
location, using the commands

```sh
sudo cp "${HOME}"/git/dotfiles/usr/local/bin/{enable,disable}-firewall.sh /usr/local/bin
sudo chmod u+x /usr/local/bin/{enable,disable}-firewall.sh
```

Next, use `systemd` to start the firewall and enable the firewall at boot

```sh
sudo cp "${HOME}/git/dotfiles/etc/systemd/system/firewall.service" /etc/systemd/system
sudo systemctl start firewall
sudo systemctl enable firewall
```

## multiple users

If you will be having multiple users on a single machine, consider setting `DIR_MODE=0750`
in `/etc/adduser.conf`.

## sudoers

Allow yourself to update and upgrade without typing in a password. This can be
done using the command `sudo visudo`, which is a safe way to edit the file
`/etc/sudoers`. I do not want the terminal to remember my password for more
that 60 seconds, which can be controlled with the `timestamp_timeout`. So, add
the line

```
Defaults	timestamp_timeout=60
```

and change the line

```
%sudo	ALL=(ALL:ALL) ALL
```

to

```
%sudo	ALL=(ALL:ALL) ALL, NOPASSWD: /usr/bin/apt-get -- update, /usr/bin/apt-get -- upgrade
```

## standard programs

Download `atom-amd64.deb` from the [homepage](https://atom.io/) and run

```sh
sudo apt-get update
sudo apt-get install ./atom-amd64.deb curl gnupg2 i3 ranger xserver-xorg-input-synaptics zathura
sudo apt-get upgrade
```

## setup

Recursively create symlinks to dotfiles

```sh
cp --force --no-dereference --preserve=all --recursive --symbolic-link --verbose -- "${HOME}/git/dotfiles/home/." "${HOME}" >"${HOME}/git/dotfiles/setup.log"
```
