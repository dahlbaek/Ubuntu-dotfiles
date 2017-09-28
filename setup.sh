#!/bin/bash

# Determine path of dotfiledir
SCRIPTDIR="$(cd "$(dirname "${0}")" && pwd)"
DOTFILEDIR="${SCRIPTDIR}/dotfiledir"

# Setup simple firewall rules
sudo "${DOTFILEDIR}/bin/iptables.sh"

# Install standard programs
sudo apt-get update
sudo apt-get install chromium-browser curl gnupg2 i3 ipython3 lynx msmtp mutt neovim offlineimap pdfgrep python3-pandas python3-pip r-base ranger texlive-full urlscan wine zathura
sudo -k

# Install vim-plug for nvim
curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

# Install nvr to enable reverse-search with vim-tex in nvim
pip3 install --upgrade pip
pip3 install --user neovim neovim-remote

# Recursively create symlinks to dotfiles
cp -asfv "${DOTFILEDIR}/." "${HOME}"

# Install plugins for nvim
nvim -c "PlugUpdate" -c "qa"

# Set restrictive permissions
find "${SCRIPTDIR}" -not -xtype l -exec chmod go-rwx '{}' \;
