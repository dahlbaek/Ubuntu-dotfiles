# config for my Debian setup

A collection of my dotfiles and other setup (mostly minor
tweaks to default configs) along with some simple setup
instructions for Debian Stretch.

## preparation

Prepare a usb drive with a hybrid-iso image, firmware and select packages to
install. First, download the git repository to a `dotfiles` folder

```sh
git clone https://github.com/dahlbaek/Debian-dotfiles.git dotfiles
```

Then, create folders to contain the other files

```sh
mkdir local install firmware
```

Next, create a file `links` in `install` which
contains links to the install files to download. The contents of `links` could look
like this:

```
https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/SHA256SUMS
https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/SHA256SUMS.sign
https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/debian-9.6.0-amd64-xfce-CD-1.iso
```

Download the files by running the command

```sh
xargs -a links -n 1 curl -L -O
```

Then download firmware files similarly in the firmware folder. In this case
an example links file could look like

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

where DF9B9C49EAA9298432589D76DA87E80D6294BE9B is an example of a key id. Next, verify
the hash of the iso, by running

```sh
sha256sum -c SHA256SUMS 2>&1 | grep OK
```

Similarly, check the hash of the firmware tarball in the `firmware` folder. Then unpack the
tarball

```sh
tar zxvf firmware.tar.gz
```

Finally, go to the `local` folder and run

```sh
FLAGS="--recurse --no-recommends --no-suggests --no-conflicts --no-breaks --no-replaces --no-enhances"
PACKAGES="apparmor apparmor-utils apparmor-profiles apt-transport-https git"
DEPENDENCIES="$(sudo apt-cache depends ${FLAGS} ${PACKAGES} | grep "^\w" | sort -u)"
sudo apt-get download ${DEPENDENCIES}
dpkg-scanpackages . | gzip > Packages.gz
```

Next, create a bootable usb drive. If the unmounted usb drive is recognized on `/dev/sdb`, go to the `install`
folder and run

```sh
sudo cp debian-9.6.0-amd64-xfce-CD-1.iso /dev/sdb
```

Next, use `fdisk` to create an extra fat16 partition (say sdb3) on the usb drive and format it by running

```sh
mkfs.vfat /dev/sdb3
```

then copy the `dotfiles`, `firmware` and `local` folders to that partition

```sh
sudo mount /dev/sdb3 /mnt -o uid=dahlbaek
cp -r firmware local dotfiles /mnt
```

Finally, unmount the usb drive

```sh
sudo umount /mnt
```

## install debian

Simply boot from the usb drive and follow the instructions. Once finished,
using the local repository on an offline machine is as easy as adding the line

```
deb [trusted=yes] file:///mnt/local ./
```

to a new file `local.list` in the folder `/etc/apt/sources.list.d`

and running

```sh
sudo apt-get update
sudo apt-get install apparmor apparmor-utils apparmor-profiles apt-transport-https git
```

Delete local.list again, and add appropriate repositories to `/etc/apt/sources.list`.
Then, copy the git repository from the usb drive

```sh
git clone /mnt/dotfiles "${HOME}/git/dotfiles"
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

## apparmor

To enable `apparmor` run

```sh
sudo mkdir -p /etc/default/grub.d
echo 'GRUB_CMDLINE_LINUX_DEFAULT="$GRUB_CMDLINE_LINUX_DEFAULT apparmor=1 security=apparmor"' | sudo tee /etc/default/grub.d/apparmor.cfg
sudo update-grub
sudo systemctl enable apparmor
```

then reboot.

## standard programs

Get the HTTPS Everywhere and NoScript Security Suite for Firefox, then download
`atom-amd64.deb` from the [homepage](https://atom.io/) and run

```sh
sudo apt-get update
sudo apt-get install ./atom-amd64.deb curl dpkg-dev dirmngr i3 ranger xserver-xorg-input-synaptics zathura
sudo apt-get upgrade
```

## setup

Recursively create symlinks to dotfiles

```sh
cp --force --no-dereference --preserve=all --recursive --symbolic-link --verbose -- "${HOME}/git/dotfiles/home/." "${HOME}" >"${HOME}/git/dotfiles/setup.log"
```
