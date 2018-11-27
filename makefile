install :
	/bin/cp --force --no-dereference --preserve=all --recursive --symbolic-link --verbose -- "${HOME}/git/dotfiles${HOME}/." "${HOME}" >"${HOME}/git/dotfiles/setup.log"
clean :
	/bin/rm "${HOME}/git/dotfiles/setup.log"
