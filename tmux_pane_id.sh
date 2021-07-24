#!/bin/bash

# function git_info() {
#   # Exit if not inside a Git repository
#   ! git rev-parse --is-inside-work-tree > /dev/null 2>&1 && return

#   # Git branch/tag, or name-rev if on detached head
#   local GIT_LOCATION=${$(git symbolic-ref -q HEAD || git name-rev --name-only --no-undefined --always HEAD)#(refs/heads/|tags/)}

#   local AHEAD="%{$fg[red]%}⇡NUM%{$reset_color%}"
#   local BEHIND="%{$fg[cyan]%}⇣NUM%{$reset_color%}"
#   local MERGING="%{$fg[magenta]%}︎%{$reset_color%}"
#   local UNTRACKED="%{$fg[red]%}●%{$reset_color%}"
#   local MODIFIED="%{$fg[yellow]%}●%{$reset_color%}"
#   local STAGED="%{$fg[green]%}●%{$reset_color%}"

#   local -a DIVERGENCES
#   local -a FLAGS

#   local NUM_AHEAD="$(git log --oneline @{u}.. 2> /dev/null | wc -l | tr -d ' ')"
#   if [ "$NUM_AHEAD" -gt 0 ]; then
#     DIVERGENCES+=( "${AHEAD//NUM/$NUM_AHEAD}" )
#   fi

#   local NUM_BEHIND="$(git log --oneline ..@{u} 2> /dev/null | wc -l | tr -d ' ')"
#   if [ "$NUM_BEHIND" -gt 0 ]; then
#     DIVERGENCES+=( "${BEHIND//NUM/$NUM_BEHIND}" )
#   fi

#   local GIT_DIR="$(git rev-parse --git-dir 2> /dev/null)"
#   if [ -n $GIT_DIR ] && test -r $GIT_DIR/MERGE_HEAD; then
#     FLAGS+=( "$MERGING" )
#   fi

#   if [[ -n $(git ls-files --other --exclude-standard 2> /dev/null) ]]; then
#     FLAGS+=( "$UNTRACKED" )
#   fi

#   if ! git diff --quiet 2> /dev/null; then
#     FLAGS+=( "$MODIFIED" )
#   fi

#   if ! git diff --cached --quiet 2> /dev/null; then
#     FLAGS+=( "$STAGED" )
#   fi

#   local -a GIT_INFO
# #   GIT_INFO+=( "\033[38;5;15m±" )
#   [ -n "$GIT_STATUS" ] && GIT_INFO+=( "$GIT_STATUS" )
#   [[ ${#DIVERGENCES[@]} -ne 0 ]] && GIT_INFO+=( "${(j::)DIVERGENCES}" )
#   [[ ${#FLAGS[@]} -ne 0 ]] && GIT_INFO+=( "${(j::)FLAGS}" )
# #   GIT_INFO+=( "\033[38;5;15m$GIT_LOCATION%{$reset_color%}" )
#   echo "${(j: :)GIT_INFO} "
# }


cd "$(tmux showenv -g TMUX_PWD_$1_$2 | sed 's/^.*=//')"

path_with_home="$(dirs)"

exit_code="$(tmux showenv -g TMUX_EXIT_CODE_$1_$2 | sed 's/^.*=//')"

exit_emoji="😎"
if [ "$exit_code" != "0" ]; then
    exit_emoji="🤯"
fi;

if [ "$exit_code" == "" ]; then
    exit_emoji="😎"
fi;

separator="#[fg=color112,bg=black]"
venv="$(tmux showenv -g TMUX_VENV_$1_$2 | sed 's/^.*=//')"
venv_formatted=""

if [ "$venv" != "" ]; then
    venv_formatted="#[fg=color160,bg=black]  $(basename $venv)"
fi;

branch_formatted=""
if [ -d .git ]; then
    branch_status=""
    current_status="$(git status -s)"
    if [ "$current_status" != "" ]; then
        branch_status=" "
    fi;
    branch_formatted="#[fg=color12,bg=black]  $(git branch --show-current) $branch_status"
    if [ "$venv_formatted" != "" ]; then
        branch_formatted="$separator$branch_formatted"
    fi;
fi;

echo "#[align=left]#[fg=color235,bg=color112]#[fg=color112,bg=color112] $exit_emoji #[bg=black]$venv_formatted $branch_formatted#[fg=black,bg=color235]#[align=right,bg=color235,fg=black]#[fg=green,bg=black] $path_with_home #[bg=black,fg=color235]"