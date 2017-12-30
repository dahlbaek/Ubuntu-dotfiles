#!/bin/sh

set -euf
IFS=''

printf "\nTHIS SCRIPT DOES NOT REQUIRE ROOT PRIVILEGES. ABORT IF IT ASKS FOR THEM.\n\n"
sleep 3

# set path variables
SCRIPTDIR="${HOME}/git/dotfiles"
DOTFILEDIR="${SCRIPTDIR}/home"

# Set simple firewall rules
sudo /bin/sh /usr/bin/iptables.sh

# Install vim-plug for nvim
curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

# Install nvr to enable reverse-search with vim-tex in nvim
pip3 install --upgrade pip
pip3 install --user neovim neovim-remote

# Recursively create symlinks to dotfiles
cp -asfv "${DOTFILEDIR}/." "${HOME}" >setup.log

# Install plugins for nvim
nvim -c "PlugUpdate" -c "qa"

# Set restrictive permissions
find "${SCRIPTDIR}" -not -xtype l -exec chmod go-rwx {} +
