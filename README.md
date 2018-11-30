# config for my Ubuntu setup

A collection of my dotfiles and other setup (mostly minor tweaks to default
configs) along with some simple setup instructions for Ubuntu Bionic Beaver.

## preparation

Prepare a usb drive with dotfiles repository and a hybrid-iso image. First,
download the git repository to a `dotfiles` folder

```sh
git clone https://github.com/dahlbaek/dotfiles.git
```

Then, create folders to contain the other files hybrid-iso image

```sh
mkdir install
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
gpg --verify SHA256SUMS.gpg SHA256SUMS
```

If the key is unknown, retrieve the key with

```sh
gpg --recv-keys 46181433FBB75451
```

where 46181433FBB75451 is an example of a key id. Next,
verify the hash of the iso, by running

```sh
sha256sum -c SHA256SUMS 2>&1 | grep OK
```

## bootable usb

Next, create a bootable usb drive. If the unmounted usb drive is recognized on
`/dev/sdb`, go to the `install` folder and run

```sh
sudo cp ubuntu-18.04.1-desktop-amd64.iso /dev/sdb
```

Next, use `sudo fdisk /dev/sdb` to create an extra ext4 partition
(say sdb3) on the usb drive and format it afterwards by running

```sh
sudo mkfs.ext4 /dev/sdb3
```

then copy the `dotfiles` folder to that partition

```sh
sudo mount /dev/sdb3 ~/mnt
sudo chown dahlbaek:dahlbaek ~/mnt
cp -r dotfiles ~/mnt
sudo umount ~/mnt
```

## install ubuntu

Simply boot from the usb drive and follow the instructions. Do not set up the
network yet. Boot into the new system and copy the git repository from the usb
drive

```sh
mkdir git && cd git
cp -r /media/dahlbaek/Ubuntu\ 18.04.1\ LTS\ amd641/dotfiles/ .
```

## multiple users

If you will be having multiple users on a single machine, consider setting
`DIR_MODE=0750` in `/etc/adduser.conf`. Also, change your own home folder to
that mode

```sh
cd /home
chmod 0750 dahlbaek
```

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
%sudo	ALL=(ALL:ALL) ALL,\
                      NOPASSWD: /usr/bin/apt-get -- update,\
                      NOPASSWD: /usr/bin/apt-get -- upgrade
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
sudo cp "${HOME}/git/dotfiles/etc/apt/sources.list" /etc/apt
```

Then set up the network and upgrade the system

```sh
update.sh
```

## apparmor and firefox

Install `apparmor-utils` and enable the apparmor firefox profile

```sh
sudo apt-get install apparmor-utils
sudo aa-enforce /etc/apparmor.d/usr.bin.firefox
```

Finally, make sure to get the HTTPS Everywhere and NoScript Security
Suite for Firefox

## setup

Recursively create symlinks to dotfiles

```sh
make
```

Delete the log by running `make clean`.

## customization

Install `fish` for a friendly interactive shell experience and
`gnome-tweak-tool` to be able to easily tweak the gnome desktop. Set `fish` as
the default shell.

```sh
sudo apt-get install fish gnome-tweak-tool ranger zathura
chsh -s "$(which fish)"
```

The tweak tool (accessed as "Tweaks") can be used to
activate the compose key and set windows to focus on
mouse-over (sloppy).

Automatic updates can be disabled in "Software and Updates".
