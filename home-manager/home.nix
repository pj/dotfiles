{ config, pkgs, lib, ... }:
{
  home.stateVersion = "22.05";

  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;

  programs.git = {
      enable = true;
      userEmail = "paul@johnson.kiwi.nz";
      userName = "Paul Johnson";
      aliases = {
        gcb = "checkout -b";
      };
      extraConfig.init.defaultBranch = "main";
    };
    programs.zsh = {
      enable = true;
      enableCompletion = true;
      autosuggestion = {
        enable = true;
      };
      history = {
        save = 100000;
        size = 100000;
      };
      initExtraFirst = ''
        export ZSH_CUSTOM="$HOME/dotfiles/zsh_themes"
      '';
      initExtra = ''
        bindkey -M viins 'kj' vi-cmd-mode
        export EDITOR=vim
      '';
      dotDir = ".config/zsh";
      oh-my-zsh = {
        enable = true;
        theme = "wezm++";
        plugins = [
          "vi-mode"
          "git"
          "autojump"
        ];
      };
      plugins = [
        {
          name = "zsh-autosuggestions";
          file = "zsh-autosuggestions.zsh";
          src = pkgs.fetchFromGitHub {
            owner = "zsh-users";
            repo = "zsh-autosuggestions";
            rev = "v0.7.0";
            sha256 = "sha256-KLUYpUu4DHRumQZ3w59m9aTW6TBKMCXl2UcKi4uMd7w=";
          };
        }

        {
          name = "zsh-fzf-history-search";
          file = "zsh-fzf-history-search.zsh";
          src = pkgs.fetchFromGitHub {
            owner = "joshskidmore";
            repo = "zsh-fzf-history-search";
            rev = "master";
            sha256 = "sha256-tQqIlkgIWPEdomofPlmWNEz/oNFA1qasILk4R5RWobY=";
          };
        }
      ];
    };
    programs.autojump.enable = true;
    programs.fzf = {
      enable = true;
      enableZshIntegration = true;
    };
    programs.tmux = {
      enable = true;
      shell = "${pkgs.zsh}/bin/zsh";
    };
    home.stateVersion = "24.05";
    # home.file.".local/share/fonts/Monaco Nerd Font Complete Mono.ttf".source = ./../../${"Monaco Nerd Font Complete Mono.ttf"};
    home.file.".tmux.conf".source = ./../../tmux.conf;
    home.file.".config/commandline_thing/config.yaml".source = ./../../commandline_thing.yaml;
    home.packages = [
      inputs.commandline_thing.packages.${pkgs.system}.default
    ];

  home.packages = with pkgs; [
    curl
    wget
    jq

  ] ++ lib.optionals stdenv.isDarwin [
  ];
}