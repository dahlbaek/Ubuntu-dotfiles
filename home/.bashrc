# source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

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

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="/home/dahlbaek/.sdkman"
[[ -s "/home/dahlbaek/.sdkman/bin/sdkman-init.sh" ]] && source "/home/dahlbaek/.sdkman/bin/sdkman-init.sh"
