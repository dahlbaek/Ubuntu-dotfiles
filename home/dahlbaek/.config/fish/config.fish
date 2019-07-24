set -l USER_BIN_DIRS $HOME/boost/bin /snap/bin $HOME/.cargo/bin $HOME/bin

for BIN_DIR in $USER_BIN_DIRS
    if test -d $BIN_DIR
        set -gx PATH $BIN_DIR $PATH
    end
end

set -gx SBT_OPTS "-Xss64m  -Xmx4G -XX:ReservedCodeCacheSize=512M"
set -gx KOPS_STATE_STORE s3://licph-kubernetes-artifacts

alias cclip "/usr/bin/xclip -selection clipboard"
alias pclip "/usr/bin/xclip -o -selection clipboard"
