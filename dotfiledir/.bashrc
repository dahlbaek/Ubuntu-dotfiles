# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

# Uncomment the following line if you don't like systemctl's auto-paging feature:
# export SYSTEMD_PAGER=

# User specific aliases and functions

# Set nvim as default editor
export EDITOR=nvim
export VISUAL="${EDITOR}"

# Clear up prompt
PS1="$ "
