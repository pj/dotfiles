{
  commandline_thing,
  customPackages ? [ ],
  customPathAdditions ? [ ],
  # List of { source = path; target = "relative/path/in/home"; } entries.
  # Each is linked into the home directory, e.g.:
  #   { source = ../some/file.json; target = "Library/Application Support/App/config.json"; }
  customFiles ? [ ],
  # Git identity. Defaults keep the repo functional without local.nix overrides.
  gitUserName ? "Unknown",
  gitUserEmail ? "unknown@example.com",
}:
{
  config,
  pkgs,
  lib,
  ...
}:
{
  #programs.direnv.enable = true;
  #programs.direnv.nix-direnv.enable = true;

  programs.git = {
    enable = true;
    settings = {
      user.email = gitUserEmail;
      user.name = gitUserName;
      alias.gcb = "checkout -b";
      init.defaultBranch = "main";
    };
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
    initContent = lib.mkMerge [
      (lib.mkBefore ''
        export ZSH_CUSTOM="$HOME/dotfiles/zsh_themes"
      '')
      ''
        bindkey -M viins 'kj' vi-cmd-mode
        export EDITOR=vim
        # Add custom paths per system
        ${lib.concatMapStringsSep "\n" (path: ''export PATH="${path}:$PATH"'') customPathAdditions}
        # Load local zshrc if it exists
        [ -f ~/.zshrc.local ] && source ~/.zshrc.local
      ''
    ];
    dotDir = "${config.xdg.configHome}/zsh";
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
  programs.vim = {
    enable = true;
    defaultEditor = true;
    extraConfig = builtins.readFile ./../vimrc;
  };

  home.stateVersion = "24.05";

  # Add custom paths to PATH per system
  home.sessionPath = customPathAdditions;

  # Static dotfile links, plus any customFiles from local.nix.
  # customFiles entries: { source = <path>; target = "relative/path/in/home"; }
  home.file = {
    ".tmux.conf".source = ./../tmux.conf;
    ".config/commandline_thing/config.yaml".source = ./../commandline_thing.yaml;
    ".config/jjui/config.toml".source = ./../jjui_config.toml;
    ".config/jj/config.toml".source = pkgs.writeText "jj-config.toml" (
      (builtins.readFile ./../jj_config.toml)
      + ''

        [user]
        name = "${gitUserName}"
        email = "${gitUserEmail}"
      ''
    );
  }
  // builtins.listToAttrs (
    map (f: {
      name = f.target;
      value = {
        source = f.source;
      };
    }) customFiles
  );

  home.packages =
    with pkgs;
    let
      jj-patch-vim = pkgs.writeShellScriptBin "jj-patch-vim" ''
        set -euo pipefail
        left="$1"
        right="$2"
        # Remove jj's synthetic instructions file so it doesn't appear in the diff
        rm -f "$right/JJ-INSTRUCTIONS"
        patch_file=$(mktemp /tmp/jj-patch-XXXXXX.patch)
        trap 'rm -f "$patch_file"' EXIT
        diff -u -r "$left" "$right" > "$patch_file" || true
        vim "$patch_file"
        # Reset right dir to match left, then apply the edited patch.
        # Patch paths are absolute (e.g. /tmp/jj-xxx/right/foo/bar.py).
        # With -d "$right", patch operates inside $right, so we strip all
        # components of $right plus one more for the filename prefix.
        # patch -p strips N leading path components (split on '/').
        # Absolute paths start with '/' giving an empty first component,
        # so -p(slashes_in_right + 1) strips everything up to and including
        # the last component of $right, leaving a path relative to it.
        strip=$(( $(echo "$right" | tr -cd '/' | wc -c | tr -d ' ') + 1 ))
        cp -r "$left/." "$right/"
        patch -d "$right" -p"$strip" < "$patch_file"
      '';
      spec-kit = pkgs.python3.pkgs.buildPythonPackage {
        pname = "specify-cli";
        version = "0.4.4";
        pyproject = true;
        src = pkgs.fetchgit {
          url = "https://github.com/github/spec-kit";
          rev = "725ef567b78e7a49f09d1771640743dcce4916cb";
          sha256 = "0gdpha8mk68kcscwyp5sryxl2ffwqrrznzb0mg7v4caf2jz2bzj2";
        };
        build-system = [ pkgs.python3.pkgs.hatchling ];
        dependencies = with pkgs.python3.pkgs; [
          typer
          click
          rich
          httpx
          platformdirs
          readchar
          truststore
          pyyaml
          packaging
          pathspec
          json5
        ];
      };
    in
    [
      curl
      wget
      jq
      commandline_thing.packages.${pkgs.stdenv.hostPlatform.system}.default
      git
      tmux
      inetutils
      pstree
      btop
      python3
      nixfmt
      fdupes
      jujutsu
      jjui
      jj-patch-vim
      spec-kit
    ]
    ++ customPackages
    ++ lib.optionals stdenv.isDarwin [ ];
}
