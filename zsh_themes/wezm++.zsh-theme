setopt PROMPT_SUBST
setopt interactivecomments
setopt PROMPT_SUBST

vim_ins_mode="0"
vim_cmd_mode="1"
vim_mode=$vim_ins_mode

function zle-keymap-select {
  vim_mode="${${KEYMAP/vicmd/${vim_cmd_mode}}/(main|viins)/${vim_ins_mode}}"
  tmux setenv -g TMUX_VIM_MODE_$(tmux display -p "#{=-1:window_id}")_$(tmux display -p "#{=-1:pane_id}") "$vim_mode"
  zle reset-prompt
}
zle -N zle-keymap-select

function zle-line-finish {
  vim_mode=$vim_ins_mode
  tmux setenv -g TMUX_VIM_MODE_$(tmux display -p "#{=-1:window_id}")_$(tmux display -p "#{=-1:pane_id}") "$vim_mode"
}
zle -N zle-line-finish

precmd() {
    local Z_LAST_RETVAL=$?
    if [ -n $TMUX ]; then
        tmux setenv -g TMUX_EXIT_CODE_$(tmux display -p "#{=-1:window_id}")_$(tmux display -p "#{=-1:pane_id}") "$Z_LAST_RETVAL"
        tmux setenv -g TMUX_PWD_$(tmux display -p "#{=-1:window_id}")_$(tmux display -p "#{=-1:pane_id}") $PWD
        tmux setenv -g TMUX_VENV_$(tmux display -p "#{=-1:window_id}")_$(tmux display -p "#{=-1:pane_id}") "$VIRTUAL_ENV"
    fi;
}

PROMPT='%{$fg[green]%}%{$reset_color%} $([ -n $TMUX ] && tmux refresh -S)'