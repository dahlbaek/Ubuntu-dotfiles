#!/bin/sh

set -euf
IFS=''

printf "\nTHIS SCRIPT DOES NOT REQUIRE ROOT PRIVILEGES. ABORT IF IT ASKS FOR THEM.\n\n"

# set path variables
SCRIPTDIR="${HOME}/git/dotfiles"
DOTFILEDIR="${SCRIPTDIR}/home"

# Set simple firewall rules
sudo /bin/sh /usr/local/bin/iptables.sh

# Install vim-plug for nvim
curl --create-dirs --fail --output ~/.local/share/nvim/site/autoload/plug.vim --silent --show-error -- https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

# Install nvr to enable reverse-search with vim-tex in nvim
pip3 install --quiet --upgrade -- pip
pip3 install --quiet --user -- neovim neovim-remote

# Recursively create symlinks to dotfiles
cp --force --no-dereference --preserve=all --recursive --symbolic-link --verbose -- "${DOTFILEDIR}/." "${HOME}" >setup.log

# Install plugins for nvim
nvim -c "PlugUpdate" -c "qa"

# Set restrictive permissions
find "${SCRIPTDIR}" -not -xtype l -exec chmod go-rwx {} +
