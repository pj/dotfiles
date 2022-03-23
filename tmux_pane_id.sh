#!/bin/bash

join_by () {
    # Argument #1 is the separator. It can be multi-character.
    # Argument #2, 3, and so on, are the elements to be joined.
    # Usage: join_by ", " "${array[@]}"
    local SEPARATOR="$1"
    shift

    local F=0
    for x in "$@"
    do
        if [[ F -eq 1 ]]
        then
            echo -n "$SEPARATOR"
        else
            F=1
        fi
        echo -n "$x"
    done
    echo
}

cd "$(tmux showenv -g TMUX_PWD_$1_$2_$3 | sed 's/^.*=//')"

left_segments=()

path_with_home="$(dirs)"

vim_mode="$(tmux showenv -g TMUX_VIM_MODE_$1_$2_$3 | sed 's/^.*=//')"
# echo "$vim_mode" >> ~/dotfiles/dump.log
if [ "$vim_mode" != "0" ]; then
    left_segments+=("#[fg=red,bg=black]")
else
    left_segments+=("#[fg=green,bg=black]")
fi;

exit_code="$(tmux showenv -g TMUX_EXIT_CODE_$1_$2_$3 | sed 's/^.*=//')"
if [ "$exit_code" != "0" ]; then
    left_segments+=("#[fg=color160,bg=black]🤬  $exit_code")
fi;

gcloud_project="$(tmux showenv -g TMUX_GCLOUD_PROJECT_$1_$2_$3 | sed 's/^.*=//')"
if [ "$gcloud_project" != "" ]; then
    left_segments+=("#[fg=color128,bg=black] $gcloud_project")
fi;

separator=" #[fg=color112,bg=black] "
venv="$(tmux showenv -g TMUX_VENV_$1_$2_$3 | sed 's/^.*=//')"
venv_formatted=""

if [ "$venv" != "" ]; then
    left_segments+=("#[fg=color160,bg=black] $(basename $venv)")
fi;

branch_formatted=""
if git status &>/dev/null; then
  branch_status=""
  current_status="$(git status -s)"
  if [ "$current_status" != "" ]; then
      branch_status=" #[fg=color160,bg=black]"
  fi;
  left_segments+=("#[fg=color12,bg=black] $(git branch --show-current)${branch_status}")
fi

left_segments_joined=$(join_by " #[fg=color112,bg=black] " "${left_segments[@]}")
echo "#[align=left]#[fg=color235,bg=black] $left_segments_joined #[fg=black,bg=color235]#[align=right,bg=color235,fg=black]#[fg=green,bg=black] $path_with_home #[bg=black,fg=color235]"