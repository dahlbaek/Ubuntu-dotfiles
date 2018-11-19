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
mkdir xfce-CD-1 firmware
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

## aptly

Untar the iso and setup modified package pool

```sh
mkdir CD-1
bsdtar -C CD-1/ -xf debian-9.6.0-amd64-xfce-CD-1.iso
chmod -R +w CD-1
aptly repo create xfce-CD-1
aptly repo add xfce-CD-1 CD-1
aptly snapshot create xfce-CD-1 from repo xfce-CD-1
PACKS_RELEASE=$(aptly repo show -with-packages xfce-CD-1 | grep "^\ " | xargs echo | sed "s/ / | /g")
PACKS_ADD="apparmor | apparmor-utils | apparmor-profiles | apt-transport-https | aptly | bsdtar | curl | dirmngr | git | i3 | isolinux | ranger | xorriso | xserver-corg-input-synaptics | zathura"
aptly -architectures="amd64" -dep-follow-recommends mirror create -filter="${PACKS_ADD} | ${PACKS_RELEASE}" -filter-with-deps -with-udebs stretch https://mirror.one.com/debian/ stretch main
aptly -architectures="amd64" -dep-follow-recommends mirror create -filter="${PACKS_ADD} | ${PACKS_RELEASE}" -filter-with-deps -with-udebs stretch-updates https://mirror.one.com/debian/ stretch-updates main
aptly -architectures="amd64" -dep-follow-recommends mirror create -filter="${PACKS_ADD} | ${PACKS_RELEASE}" -filter-with-deps -with-udebs stretch-security http://security.debian.org/debian-security stretch/updates main
aptly mirror update stretch
aptly mirror update stretch-updates
aptly mirror update stretch-security
aptly snapshot create stretch from mirror stretch
aptly snapshot create stretch-updates from mirror stretch-updates
aptly snapshot create stretch-security from mirror stretch-security
aptly snapshot merge xfce-CD-1-mod xfce-CD-1 stretch stretch-updates stretch-security
aptly publish snapshot -distribution="stretch" -origin="Debian" -label="Debian" -skip-signing xfce-CD-1-mod xfce-CD-1-mod
```

Simply replace the `pool` and `dists/stretch` folders in `CD-1` by those
created by aptly, then regenerate `md5sum.txt`

```sh
rm -r CD-1/pool
rm -r CD-1/dists/stretch
cp -r ~/.aptly/public/xfce-CD-1-mod/dists/stretch CD-1/dists
cp -r ~/.aptly/public/xfce-CD-1-mod/pool CD-1
cd CD-1; md5sum `find ! -name "md5sum.txt" ! -path "./isolinux/*" -follow -type f` > md5sum.txt; cd ..
```

There will be a loop warning, simply disregard. Now create a new hybrid image `test.iso`

```sh
chmod -R -w cd
dd if=debian-9.6.0-amd64-xfce-CD-1.iso bs=1 count=432 of=isohdpfx.bin
xorriso -as mkisofs -o test.iso -isohybrid-mbr isohdpfx.bin -c isolinux/boot.cat -b isolinux/isolinux.bin -no-emul-boot -boot-load-size 4 -boot-info-table ./CD-1
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
```

Finally, unmount the usb drive

```sh
sudo umount /mnt
```

To remove everything again, run

```sh
aptly publish drop stretch xfce-CD-1-mod
aptly snapshot drop xfce-CD-1-mod
aptly snapshot drop xfce-CD-1
aptly snapshot drop stretch
aptly snapshot drop stretch-updates
aptly snapshot drop stretch-security
aptly repo drop xfce-CD-1
aptly mirror drop stretch
aptly mirror drop stretch-updates
aptly mirror drop stretch-security
rm -r CD-1
```

## install debian

Simply boot from the usb drive and follow the instructions. Then copy the git
repository from the usb drive

```sh
cp -r /mnt/dotfiles "${HOME}/git/dotfiles"
```

Add appropriate repositories to `/etc/apt/sources.list`

```sh
sudo cp "${HOME}/git/dotfiles/etc/apt/sources.list" /etc/apt/sources.list
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

Profiles are located in `/etc/apparmor.d/`, with additional profiles in
`/usr/share/doc/apparmor-profiles/extras/`. For instance, enable the Firefox
profiles by running

```sh
cd /usr/share/doc/apparmor-profiles/extras
sudo cp -i *firefox* /etc/apparmor.d/
for f in *firefox* ; do sudo aa-enforce /etc/apparmor.d/$f; done
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

## installation of .deb packages

Get the HTTPS Everywhere and NoScript Security Suite for Firefox, then download
`atom-amd64.deb` from the [homepage](https://atom.io/) and run

```sh
sudo apt-get update
sudo apt-get install ./atom-amd64.deb
sudo apt-get upgrade
```

## setup

Recursively create symlinks to dotfiles

```sh
cp --force --no-dereference --preserve=all --recursive --symbolic-link --verbose -- "${HOME}/git/dotfiles/home/." "${HOME}" >"${HOME}/git/dotfiles/setup.log"
```
