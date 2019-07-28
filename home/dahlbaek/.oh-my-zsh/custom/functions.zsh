intellij () {
        nohup intellij-idea-community "$@" > /dev/null 2>&1 &
        disown
}

