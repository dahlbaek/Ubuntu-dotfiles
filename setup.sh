#!/bin/bash

# Determine path of dotfiledir
DOTFILEDIR="$(cd "$(dirname "${0}")" && cd ./dotfiledir && pwd)"

# Setup simple firewall rules
sudo "${DOTFILEDIR}/bin/iptables.sh"

# Install standard programs
sudo apt-get update
sudo apt-get install chromium-browser curl i3 neovim python3-pip r-base ranger texlive-full zathura
sudo -k

# Install vim-plug for vim and nvim
curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

# Install nvr to enable reverse-search with vim-tex in nvim
pip3 install --upgrade pip
pip3 install neovim-remote

# Recursively create symlinks to dotfiles
cp -asfv "${DOTFILEDIR}/." "${HOME}"

# Install plugins for vim and nvim
vim -c "PlugUpdate" -c "qa"
nvim -c "PlugUpdate" -c "qa"
