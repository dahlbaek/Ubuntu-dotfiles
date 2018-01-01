# check that HOME and USER are set correctly
printf "Welcome back ${USER}. Currently working in directory ${HOME}\n\n"


# set PATH
PATH="${HOME}/bin:${HOME}/.local/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

# source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

# set nvim as default editor
export EDITOR=nvim
export VISUAL="${EDITOR}"

# clear up prompt
PS1="$ "

# enable color support of ls and grep
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'

    alias grep='grep --color=auto'
fi

# enable bash completion in interactive shells
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

# disable XOFF and XON, which hang/unhang the terminal on <C-s> and <C-q>
stty -ixon

# set restrictive umask
umask 0077

# recommended setting by gpg-agent
GPG_TTY=$(tty)
export GPG_TTY
