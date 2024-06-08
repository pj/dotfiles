#!/bin/sh

function bootstrap() {
    # Check if curl is installed
    if !type "curl" > /dev/null; then
        echo "curl not found, will try to install"

        if !type "apk" > /dev/null; then 
            apk update && apk upgrade && apk add curl
        elif !type "apt" > /dev/null; then 
            apt update && apt upgrade && apt install -y curl
        else
            echo "unable to find or install curl, aborting"
            exit 1
        fi
    fi

    # Install packages
    mkdir -p ~/bin

    # Detect arch
    ARCH="$(uname -p)"

    # Download dotfiles


    # Link vimrc basic

    # Link bashrc basic

    # Install vim


    # Install kubectl

    # Install k3s

    # Install jq

    # Install yq
}

bootstrap