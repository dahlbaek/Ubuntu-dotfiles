#!/bin/sh

/bin/cp --force --no-dereference --preserve=all --recursive --symbolic-link --verbose -- "${HOME}/projects/dotfiles${HOME}/." "${HOME}" >"${HOME}/projects/dotfiles/setup.log"
