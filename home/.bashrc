# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

# Set nvim as default editor
export EDITOR=nvim
export VISUAL="${EDITOR}"

# Clear up prompt
PS1="$ "

# Enable color support of ls and grep
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'

    alias grep='grep --color=auto'
fi

# Enable bash completion in interactive shells
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

# Disable XOFF and XON, which hang/unhang the terminal on <C-s> and <C-q>
stty -ixon

# Set restrictive umask
umask 0077

# Recommended setting by gpg-agent
GPG_TTY=$(tty)
export GPG_TTY
