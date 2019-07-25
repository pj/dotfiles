setopt PROMPT_SUBST
setopt interactivecomments
setopt PROMPT_SUBST

vim_ins_mode="%{${fg_bold[green]}%}פֿ%{$reset_color%}"
vim_cmd_mode="%{${fg_bold[red]}%}%{$reset_color%}"
vim_mode=$vim_ins_mode

function zle-keymap-select {
  vim_mode="${${KEYMAP/vicmd/${vim_cmd_mode}}/(main|viins)/${vim_ins_mode}}"
  zle reset-prompt
}
zle -N zle-keymap-select

function zle-line-finish {
  vim_mode=$vim_ins_mode
}
zle -N zle-line-finish

PROMPT='$(git_prompt_info)${vim_mode} '
RPROMPT='%(?,,%{${fg_bold[white]}%}%?%{$reset_color%}) %{$fg[green]%}%~%{$reset_color%}'

ZSH_THEME_GIT_PROMPT_PREFIX="%{$FG[039]%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%} "
ZSH_THEME_GIT_PROMPT_DIRTY="%{$FG[039]%}%{$fg[red]%}✗%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_CLEAN="%{$FG[039]%}"
