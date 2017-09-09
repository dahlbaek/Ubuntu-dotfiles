#!/bin/bash

# Install standard programs
apt-get update
sudo -k apt-get install chromium i3 neovim python3-pip r-base ranger texlive-full zathura

# Install vim-plug for vim and nvim
curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

# Install nvr to enable reverse-search with vim-tex in nvim
pip3 install neovim-remote

# Recursively create symlinks to dotfiles
DOTFILEDIR="$(cd "$(dirname "${0}")" && cd ./dotfiledir && pwd)"
cp -asfv "${DOTFILEDIR}/." "${HOME}"

# Install plugins for vim and nvim
vim -c "PlugUpdate" -c "qa"
nvim -c "PlugUpdate" -c "qa"
