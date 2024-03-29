setopt PROMPT_SUBST
setopt interactivecomments
setopt PROMPT_SUBST

vim_ins_mode="0"
vim_cmd_mode="1"
vim_mode=$vim_ins_mode

function zle-keymap-select {
  vim_mode="${${KEYMAP/vicmd/${vim_cmd_mode}}/(main|viins)/${vim_ins_mode}}"
  if [[ -n $TMUX ]]; then
    tmux setenv -g TMUX_VIM_MODE_$(tmux display -p "#{=-1:session_id}")_$(tmux display -p "#{=-1:window_id}")_$(tmux display -p "#{=-1:pane_id}") "$vim_mode"
    tmux refresh -S
  fi;
  zle reset-prompt
}
zle -N zle-keymap-select

function zle-line-finish {
  vim_mode=$vim_ins_mode
  if [[ -n $TMUX ]]; then
    tmux setenv -g TMUX_VIM_MODE_$(tmux display -p "#{=-1:session_id}")_$(tmux display -p "#{=-1:window_id}")_$(tmux display -p "#{=-1:pane_id}") "$vim_mode"
    tmux refresh -S
  fi;
}
zle -N zle-line-finish

function set-gcloud {
  SESSION_ID=$(tmux display -p "#{=-1:session_id}")
  WINDOW_ID=$(tmux display -p "#{=-1:window_id}")
  PANE_ID=$(tmux display -p "#{=-1:pane_id}")
  IDS="_${SESSION_ID}_${WINDOW_ID}_${PANE_ID}"
#  if type "gcloud" > /dev/null && gcloud projects list > /dev/null 2>&1 ; then
#    tmux setenv -g "TMUX_GCLOUD_PROJECT${IDS}" "$(gcloud config get-value project)"
#    tmux refresh-client -S
#  fi
}

function update-tmux-variables  {
    local Z_LAST_RETVAL=$?
    if [[ -n $TMUX ]]; then
        SESSION_ID=$(tmux display -p "#{=-1:session_id}")
        WINDOW_ID=$(tmux display -p "#{=-1:window_id}")
        PANE_ID=$(tmux display -p "#{=-1:pane_id}")
        IDS="_${SESSION_ID}_${WINDOW_ID}_${PANE_ID}"
        tmux setenv -g "TMUX_EXIT_CODE${IDS}" "$Z_LAST_RETVAL"
        tmux setenv -g "TMUX_PWD${IDS}" $PWD
        tmux setenv -g "TMUX_VENV${IDS}" "$VIRTUAL_ENV"
        tmux refresh-client -S
        #(set-gcloud &)
    fi;
}

precmd() {
    update-tmux-variables
}

PROMPT='%{$fg[green]%}%{$reset_color%} $(update-tmux-variables)'
