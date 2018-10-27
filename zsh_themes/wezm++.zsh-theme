setopt PROMPT_SUBST
setopt interactivecomments
setopt PROMPT_SUBST

vim_ins_mode="%{${fg_bold[red]}%}Insert%{$reset_color%}"
vim_cmd_mode="%{${fg_bold[green]}%}Normal%{$reset_color%}"
vim_mode=$vim_ins_mode

function zle-keymap-select {
  vim_mode="${${KEYMAP/vicmd/${vim_cmd_mode}}/(main|viins)/${vim_ins_mode}}"
  zle reset-prompt
    #if [ $KEYMAP = vicmd ]; then
    #    # the command mode for vi
    #    echo -ne "\e[2 q"
    #else
    #    # the insert mode for vi
    #    echo -ne "\e[4 q"
    #fi
}
zle -N zle-keymap-select

function zle-line-finish {
  vim_mode=$vim_ins_mode
}
zle -N zle-line-finish

PROMPT='${vim_mode} %{${fg_bold[yellow]}%}%n%{$reset_color%} $(git_prompt_info)%(?,,%{${fg_bold[white]}%}[%?]%{$reset_color%} )%{$fg[yellow]%}%#%{$reset_color%} '
RPROMPT='%{$fg[green]%}%~%{$reset_color%}'
# %{$(pwd|grep --color=always /)%${#PWD}G'

ZSH_THEME_GIT_PROMPT_PREFIX="%{$fg[blue]%}("
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%} "
ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[blue]%})%{$fg[red]%}✗%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_CLEAN="%{$fg[blue]%})"

# %{${fg[yellow]}%}@%m%{$reset_color%}
