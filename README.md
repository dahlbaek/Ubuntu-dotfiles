# dotfiles for my Ubuntu setup

A collection of my dotfiles (mostly minor tweaks to default configs) along with
some simple setup instructions for Ubuntu 16.04.

## standard programs

In order to have my favourite programs available, run the commands

```
sudo apt-get update
sudo apt-get install chromium-browser curl git gnupg2 i3 ipython3 lynx msmtp mutt neovim offlineimap pdfgrep postgresql-client postgresql postgresql-contrib python3-pip r-base ranger texlive-full urlscan wine xdotool zathura
sudo apt-get upgrade
```

## clone the repository

Further instructions and scripts assume that `git` has been used to clone the
repository to `~/git/dotfiles`.

## iptables

Copy the `iptables.sh` script to a secure location, using the command

```
sudo cp "${HOME}/git/dotfiles/home/.config/iptables/iptables.sh" /usr/local/bin/iptables.sh
```

You may need to create one or more directories first.

## sudoers

Allow yourself to update, upgrade and set iptables rules without typing in a
password. This can be done using the command `sudo visudo`, which is a safe way
to edit the file `/etc/sudoers`. I do not want the terminal to remember my
password, which can be controlled with the `timestamp_timeout`. So, add the line

```
Defaults	timestamp_timeout=0
```

and change the line

```
%sudo	ALL=(ALL:ALL) ALL
```

to

```
%sudo	ALL=(ALL:ALL) ALL, NOPASSWD: /usr/bin/apt-get -- update, /usr/bin/apt-get -- upgrade, /bin/sh -- /usr/local/bin/iptables.sh
```

## setup

The setup script `setup.sh` sources the `iptables.sh` file, installs vim-plug for
nvim, installs nvr for vim-tex, puts symbolic links to the included config
files, installs plugins for nvim and sets restrictive permissions for those
files. Run the setup script with the command `"${HOME}/git/dotfiles/setup.sh"`.
Beware, however, that the setup script is destructive. Any config files that
get in the way are lost.

As noted in the file `iptables.sh`, if you want to preserve firewall rules
between sessions (and you do), you need to add `iptables-restore <
/etc/firewall.conf` to `/etc/rc.local`.
