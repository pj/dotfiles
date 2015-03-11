#!/bin/sh

if ! [ -d "$HOME/dotfiles" ]; then 
    echo "$HOME/dotfiles not found"
    exit 1
fi

if ! [ -f "$HOME/bin/kubectl" ]; then 
    echo "$HOME/bin/kubectl not found"
    exit 1
fi
"$HOME/bin/kubectl" -h

if ! [ -f "$HOME/bin/k9s" ]; then 
    echo "$HOME/bin/k9s not found"
    exit 1
fi
"$HOME/bin/k9s" -h

if ! [ -f "$HOME/bin/jq" ]; then 
    echo "$HOME/bin/jq not found"
    exit 1
fi
"$HOME/bin/jq" -h

if ! [ -f "$HOME/bin/yq" ]; then 
    echo "$HOME/bin/yq not found"
    exit 1
fi
"$HOME/bin/yq" -h
