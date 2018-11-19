# config for my Ubuntu setup

A collection of my dotfiles and other setup (mostly minor tweaks to default
configs) along with some simple setup instructions for Ubuntu Bionic Beaver.

## preparation

Prepare a usb drive with dotfiles repository, a hybrid-iso image and non-free
firmware. First, download the git repository to a `dotfiles` folder

```sh
git clone https://github.com/dahlbaek/dotfiles.git
```

Then, create folders to contain the other files

```sh
mkdir install firmware
```

Next, create a file `links` in `install` which contains links to the install
files to download. The contents of `links` could look like this:

```
https://mirror.one.com/ubuntu-cd/18.04/SHA256SUMS
https://mirror.one.com/ubuntu-cd/18.04/SHA256SUMS.gpg
https://mirror.one.com/ubuntu-cd/18.04/ubuntu-18.04.1-desktop-amd64.iso
```

Download the files by running the command

```sh
xargs -a links -n 1 curl -L -O
```

In the `install` folder, verify that `SHA256SUMS` is correctly signed by running

```sh
gpg --verify SHA256SUMS.sign SHA256SUMS
```

If the key is unknown, retrieve the key with

```sh
gpg --recv-keys DF9B9C49EAA9298432589D76DA87E80D6294BE9B
```

where DF9B9C49EAA9298432589D76DA87E80D6294BE9B is an example of a key id. Next,
verify the hash of the iso, by running

```sh
sha256sum -c SHA256SUMS 2>&1 | grep OK
```

## bootable usb

Next, create a bootable usb drive. If the unmounted usb drive is recognized on `/dev/sdb`, go to the `install`
folder and run

```sh
sudo cp ubuntu-18.04.1-desktop-amd64.iso /dev/sdb
```

Next, use `fdisk` to create an extra ext4 partition (say sdb3) on the usb drive and format it by running

```sh
mkfs.ext4 /dev/sdb3
```

then copy the `dotfiles` folder to that partition

```sh
sudo mount /dev/sdb3 /mnt -o uid=dahlbaek
cp -r dotfiles /mnt
sudo umount /mnt
```

## install ubuntu

Simply boot from the usb drive and follow the instructions. Do not set up the
network yet. Boot into the new system, mount the usb and copy the git repository
from the usb drive

```sh
sudo mount /dev/sdb1 /
sudo mount /dev/sdb3 /mnt -o uid=dahlbaek
cp -r /mnt/dotfiles "${HOME}/git/dotfiles"
sudo apt-get update
sudo apt-get install apt-transport-https
sudo apt-get upgrade
```

## multiple users

If you will be having multiple users on a single machine, consider setting `DIR_MODE=0750`
in `/etc/adduser.conf`.

## sudoers

Allow yourself to update and upgrade without typing in a
password. This can be done using the command `sudo visudo`, which is a safe way
to edit the file `/etc/sudoers`. I do not want the terminal to remember my
password for more than 1 minute, which can be controlled with the `timestamp_timeout`. So, add the line

```
Defaults	timestamp_timeout=1
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
sudo apt-get install ./atom-amd64.deb curl gnupg2 i3 ranger zathura
sudo apt-get upgrade
```

## iptables and network

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

Add appropriate repositories to `/etc/apt/sources.list` and upgrade the system

```sh
sudo apt-get update
sudo apt-get upgrade
```

## setup

Recursively create symlinks to dotfiles

```sh
cp --force --no-dereference --preserve=all --recursive --symbolic-link --verbose -- "${HOME}/git/dotfiles/home/." "${HOME}" >"${HOME}/git/dotfiles/setup.log"
```
