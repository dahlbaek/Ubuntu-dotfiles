# config for my Debian setup

A collection of my dotfiles and other setup (mostly minor
tweaks to default configs) along with some simple setup
instructions for Debian Stretch.

## preparation

Prepare a usb drive with dotfiles repository, a hybrid-iso image and non-free
firmware. First, download the git repository to a `dotfiles` folder

```sh
git clone https://github.com/dahlbaek/dotfiles.git
```

Then, create folders to contain the other files

```sh
mkdir xfce-CD-1 firmware
```

Next, create a file `links` in `xfce-CD-1` which contains links to the install
files to download. The contents of `links` could look like this:

```
https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/SHA256SUMS
https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/SHA256SUMS.sign
https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/debian-9.6.0-amd64-xfce-CD-1.iso
```

Download the files by running the command

```sh
xargs -a links -n 1 curl -L -O
```

Then download firmware files similarly in the firmware folder. In this case an
example `links` file could look like

```
https://cdimage.debian.org/cdimage/unofficial/non-free/firmware/stretch/20181110/SHA256SUMS
https://cdimage.debian.org/cdimage/unofficial/non-free/firmware/stretch/20181110/firmware.tar.gz
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

Similarly, check the hash of the firmware tarball in the `firmware` folder.
Then unpack the tarball

```sh
tar zxvf firmware.tar.gz
```

## bootable usb

Next, create a bootable usb drive. If the unmounted usb drive is recognized on `/dev/sdb`, go to the `install`
folder and run

```sh
sudo cp test.iso /dev/sdb
```

Next, use `fdisk` to create an extra ext4 partition (say sdb3) on the usb drive and format it by running

```sh
mkfs.ext4 /dev/sdb3
```

then copy the `dotfiles` and `firmware` folders to that partition

```sh
sudo mount /dev/sdb3 /mnt -o uid=dahlbaek
cp -r dotfiles firmware /mnt
sudo umount /mnt
```

## install debian

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

Allow yourself to update and upgrade without typing in a password. This can be
done using the command `sudo visudo`, which is a safe way to edit the file
`/etc/sudoers`. I do not want the terminal to remember my password for more
than 1 minute, which can be controlled with the `timestamp_timeout`. So, add
the line

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

Add appropriate repositories to `/etc/apt/sources.list`

```sh
sudo cp "${HOME}/git/dotfiles/etc/apt/sources.list" /etc/apt/sources.list
```

Then start the network (if necessary, install the non-free firmware first).
Install `apparmor`, enable `apparmor` at boot, confine firefox, then reboot

```sh
sudo apt-get install apparmor apparmor-utils apparmor-profiles
sudo mkdir -p /etc/default/grub.d
echo 'GRUB_CMDLINE_LINUX_DEFAULT="$GRUB_CMDLINE_LINUX_DEFAULT apparmor=1 security=apparmor"' | sudo tee /etc/default/grub.d/apparmor.cfg
sudo update-grub
sudo systemctl enable apparmor
cd /usr/share/doc/apparmor-profiles/extras
sudo cp -i *firefox* /etc/apparmor.d/
for f in *firefox* ; do sudo aa-enforce /etc/apparmor.d/$f; done
sudo reboot
```

After the reboot, upgrade the system

```sh
sudo apt-get update
sudo apt-get upgrade
```

Then make sure to get the HTTPS Everywhere and NoScript Security Suite for
Firefox

## setup

Recursively create symlinks to dotfiles

```sh
cp --force --no-dereference --preserve=all --recursive --symbolic-link --verbose -- "${HOME}/git/dotfiles/home/." "${HOME}" >"${HOME}/git/dotfiles/setup.log"
```
