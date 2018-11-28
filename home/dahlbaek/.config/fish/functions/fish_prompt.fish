function fish_prompt --description 'Write out the prompt'
    echo -n -s $USER ' '
    set_color $fish_color_cwd
    echo -n (prompt_pwd)
    set_color normal
    echo -n "> "
end
