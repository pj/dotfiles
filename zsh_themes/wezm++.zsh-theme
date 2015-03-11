setopt PROMPT_SUBST
setopt interactivecomments
setopt PROMPT_SUBST

vim_ins_mode="0"
vim_cmd_mode="1"
vim_mode=$vim_ins_mode

function zle-keymap-select {
  vim_mode="${${KEYMAP/vicmd/${vim_cmd_mode}}/(main|viins)/${vim_ins_mode}}"
  if [[ -n $TMUX ]]; then
    (commandline_thing set-state pane "$(tmux display -p "#{=-1:session_id}:#{=-1:window_id}.#{=-1:pane_id}")" vim $vim_mode > /dev/null 2>&1 &)
  else
    (commandline_thing set-state prompt "$$" vim $vim_mode > /dev/null 2>&1 &)
    (commandline_thing set-state rprompt "$$" vim $vim_mode > /dev/null 2>&1 &)
  fi;
  zle reset-prompt
}
zle -N zle-keymap-select

function zle-line-finish {
  vim_mode=$vim_ins_mode
  if [[ -n $TMUX ]]; then
    (commandline_thing set-state pane "$(tmux display -p "#{=-1:session_id}:#{=-1:window_id}.#{=-1:pane_id}")" vim $vim_mode > /dev/null 2>&1 &)
  else
    (commandline_thing set-state prompt "$$" vim $vim_mode > /dev/null 2>&1 &)
    (commandline_thing set-state rprompt "$$" vim $vim_mode > /dev/null 2>&1 &)
  fi;
}
zle -N zle-line-finish

function update-tmux-variables  {
    local Z_LAST_RETVAL=$?
    if [[ -n $TMUX ]]; then
        IDS="$(tmux display -p "#{=-1:session_id}:#{=-1:window_id}.#{=-1:pane_id}")"
        (commandline_thing set-state pane "$IDS" exit_code "$Z_LAST_RETVAL" > /dev/null 2>&1 &)
        (commandline_thing set-state pane "$IDS" venv "$VIRTUAL_ENV" > /dev/null 2>&1 &)
    else
        (commandline_thing set-state prompt "$$" exit_code "$Z_LAST_RETVAL" > /dev/null 2>&1 &)
        (commandline_thing set-state prompt "$$" venv "$VIRTUAL_ENV" > /dev/null 2>&1 &)
        (commandline_thing set-state rprompt "$$" exit_code "$Z_LAST_RETVAL" > /dev/null 2>&1 &)
        (commandline_thing set-state rprompt "$$" venv "$VIRTUAL_ENV" > /dev/null 2>&1 &)
    fi;
}

add-zsh-hook precmd update-tmux-variables

PROMPT='$(commandline_thing generate prompt "$(if [[ -n $TMUX ]]; then tmux display -p "#{=-1:session_id}:#{=-1:window_id}.#{=-1:pane_id}"; else echo "$$"; fi)" "$(pwd)")'
RPROMPT='$(commandline_thing generate rprompt "$(if [[ -n $TMUX ]]; then tmux display -p "#{=-1:session_id}:#{=-1:window_id}.#{=-1:pane_id}"; else echo "$$"; fi    )" "$(pwd)")'
