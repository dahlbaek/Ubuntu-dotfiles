set -l USER_BIN_DIRS /snap/bin $HOME/.cargo/bin $HOME/bin

for BIN_DIR in $USER_BIN_DIRS
    if test -d $BIN_DIR
        set -gx PATH $BIN_DIR $PATH
    end
end
