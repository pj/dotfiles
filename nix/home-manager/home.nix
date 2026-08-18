{
  commandline_thing,
  window_thing,
  customPackages ? [ ],
  customPathAdditions ? [ ],
  # List of { source = path; target = "relative/path/in/home"; } entries.
  # Each is linked into the home directory, e.g.:
  #   { source = ../some/file.json; target = "Library/Application Support/App/config.json"; }
  customFiles ? [ ],
  # Git identity. Defaults keep the repo functional without local.nix overrides.
  gitUserName ? "Unknown",
  gitUserEmail ? "unknown@example.com",
  # Arbitrary shell environment variables. Passed straight to
  # home.sessionVariables. Empty {} = none.
  environmentVariables ? { },
  # Nix HTTP fetcher access tokens (host -> token). When non-empty, lands in
  # ~/.config/nix/nix.conf as a single access-tokens line.
  nixAccessTokens ? { },
  # Per-scope npm registry config: { <scope> = { url; authToken; }; }.
  # When non-empty, lands in ~/.npmrc.
  npmScopedRegistries ? { },
  # Global npm packages to install via `npm install -g --prefix=$HOME/.local`
  # on every home-manager activation. Pin versions with `pkg@x.y.z`.
  # Auth flows through ~/.npmrc (set via npmScopedRegistries above).
  # Note: removing a package here does NOT auto-uninstall it - use
  # `npm uninstall -g --prefix=$HOME/.local <pkg>` manually.
  globalNpmPackages ? [ ],
}:
{
  config,
  pkgs,
  lib,
  ...
}:
let
  # The prebuilt, Developer ID signed release — not a source build. macOS keys
  # the Accessibility grant to the code signature, so an unsigned build would
  # lose its permission on every upgrade.
  windowThing = window_thing.packages.${pkgs.stdenv.hostPlatform.system}.default;
  windowThingApp = "${windowThing}/Applications/WindowThing.app";

  hasNixAccessTokens = nixAccessTokens != { };
  hasNpmConfig = npmScopedRegistries != { };
  hasGlobalNpmPackages = globalNpmPackages != [ ];

  # "https://npm.pkg.github.com" -> "//npm.pkg.github.com/"
  # (npm's .npmrc keys auth lines by URL minus scheme, with trailing slash.)
  npmAuthKey =
    registry:
    let
      noScheme = builtins.replaceStrings [ "https://" "http://" ] [ "" "" ] registry;
      withSlash = if lib.hasSuffix "/" noScheme then noScheme else noScheme + "/";
    in
    "//" + withSlash;

  # "<scope>:registry=<url>" line per entry.
  npmScopeLines = lib.mapAttrsToList (scope: r: "${scope}:registry=${r.url}") npmScopedRegistries;

  # Group entries by url so we emit one auth line per unique registry.
  # If two scopes point to the same url with different authTokens, the first
  # one wins (user is responsible for keeping them consistent).
  npmEntriesByUrl = lib.groupBy (r: r.url) (lib.attrValues npmScopedRegistries);

  npmAuthLines = lib.mapAttrsToList (
    url: entries: "${npmAuthKey url}:_authToken=${(builtins.head entries).authToken}"
  ) npmEntriesByUrl;

  npmrcText = lib.concatStringsSep "\n" (npmScopeLines ++ npmAuthLines) + "\n";

  # macOS notifier for the Claude Code hook below. Prebuilt arm64 binary from
  # the alerter release; terminal-notifier is unreliable on macOS Tahoe, and
  # alerter is not packaged in nixpkgs/homebrew.
  alerter = pkgs.stdenvNoCC.mkDerivation {
    pname = "alerter";
    version = "26.5";
    src = pkgs.fetchurl {
      url = "https://github.com/vjeantet/alerter/releases/download/v26.5/alerter-26.5.zip";
      hash = "sha256-EfY83cm7P4VU7Zt2JjKhIM+nvuBePAnWVzSCPgnSTxA=";
    };
    nativeBuildInputs = [ pkgs.unzip ];
    # The zip holds a single `alerter` file (no dir), so the default unpack
    # phase errors; unzip it ourselves in installPhase instead.
    dontUnpack = true;
    dontStrip = true; # stripping breaks the Mach-O signature; macOS won't run it
    installPhase = ''
      runHook preInstall
      unzip $src
      install -Dm755 alerter $out/bin/alerter
      runHook postInstall
    '';
  };

  # Claude Code Notification-hook handler: when Claude needs input it fires a
  # clickable macOS notification. Clicking it brings the terminal to the front
  # first, then switches tmux to Claude's pane (pulls attached clients to that
  # session); nothing switches until you click. Reads the hook JSON on stdin.
  # Override the terminal focused on click with $CLAUDE_NOTIFY_BUNDLE (defaults
  # to MemeTerminal). tmux context comes from the $TMUX_PANE Claude Code inherits
  # when launched inside tmux.
  claudeNotifyHook = pkgs.writeShellScriptBin "claude-notify-hook" ''
    set -euo pipefail

    tmux=${pkgs.tmux}/bin/tmux
    jq=${pkgs.jq}/bin/jq
    alerter=${alerter}/bin/alerter

    # Logging for debugging. Tail it with:
    #   tail -f ~/.claude/claude-notify-hook.log
    # Disable by pointing CLAUDE_NOTIFY_LOG at /dev/null.
    LOG=''${CLAUDE_NOTIFY_LOG:-$HOME/.claude/claude-notify-hook.log}
    mkdir -p "$(dirname "$LOG")" 2>/dev/null || true
    log() { printf '%s [%s] %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$$" "$*" >> "$LOG" 2>/dev/null || true; }

    log "=== invoked ==="
    log "PATH=$PATH"
    log "TMUX=''${TMUX:-<unset>} TMUX_PANE=''${TMUX_PANE:-<unset>} TERM_PROGRAM=''${TERM_PROGRAM:-<unset>}"
    log "alerter=$alerter (exists: $([ -x "$alerter" ] && echo yes || echo no))"

    input=$(cat)
    log "stdin: $input"
    message=$(printf '%s' "$input" | "$jq" -r '.message // "Claude needs your input"' 2>/dev/null || printf 'Claude needs your input')
    bundle=''${CLAUDE_NOTIFY_BUNDLE:-com.googlecode.iterm2.meme}
    log "message=$message bundle=$bundle"

    pane=""
    session=""
    subtitle=""
    if [ -n "''${TMUX:-}" ] && [ -n "''${TMUX_PANE:-}" ]; then
      pane=$TMUX_PANE
      session=$("$tmux" display-message -p -t "$pane" '#{session_name}' 2>/dev/null || true)
      winidx=$("$tmux" display-message -p -t "$pane" '#{window_index}' 2>/dev/null || true)
      winname=$("$tmux" display-message -p -t "$pane" '#{window_name}' 2>/dev/null || true)
      subtitle="$session:$winidx $winname"
      log "tmux context: pane=$pane session=$session subtitle=$subtitle"
    else
      log "not inside tmux (or TMUX_PANE unset) - notification only, no teleport target"
    fi

    # Clickable notification, backgrounded so the hook returns immediately.
    # Only ON CLICK (activationType=contentClicked) do we switch: activate
    # Claude's window+pane, pull every attached client to that session, and
    # bring the terminal to the front. No switching happens otherwise.
    (
      log "firing alerter (timeout 120s, blocks until click/timeout)"
      result=$("$alerter" --title "Claude Code" --subtitle "$subtitle" \
        --message "$message" --sound default --timeout 120 --json 2>>"$LOG" || true)
      log "alerter result: $result"
      activation=$(printf '%s' "$result" | "$jq" -r '.activationType // ""' 2>/dev/null || true)
      log "activationType=$activation"
      # alerter v26.5 reports a body click as "contentsClicked"; older/other
      # builds use "contentClicked". Accept both.
      if [ "$activation" = "contentsClicked" ] || [ "$activation" = "contentClicked" ]; then
        log "clicked - focusing $bundle first, then switching tmux"
        /usr/bin/open -b "$bundle" 2>>"$LOG" || true
        if [ -n "$pane" ]; then
          "$tmux" select-window -t "$pane" 2>>"$LOG" || true
          "$tmux" select-pane -t "$pane" 2>>"$LOG" || true
          if [ -n "$session" ]; then
            "$tmux" list-clients -F '#{client_name}' 2>/dev/null | while IFS= read -r c; do
              "$tmux" switch-client -c "$c" -t "$session" 2>>"$LOG" || true
            done
          fi
        fi
      fi
      log "background handler done"
    ) >/dev/null 2>&1 &

    log "returning (alerter running in background, pid $!)"
    exit 0
  '';

  # access-tokens = host1=tok1 host2=tok2 ...
  accessTokensValue = lib.concatStringsSep " " (
    lib.mapAttrsToList (host: token: "${host}=${token}") nixAccessTokens
  );
in
{
  imports = [ ./macos-defaults.nix ];
  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;

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
      ''
      (builtins.readFile ./../meme.sh)
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

  # Arbitrary shell env vars passed in from local.nix. Empty {} = no-op.
  home.sessionVariables = environmentVariables;

  # Static dotfile links, plus any customFiles from local.nix.
  # customFiles entries: { source = <path>; target = "relative/path/in/home"; }
  home.file = {
    ".tmux.conf".source = ./../tmux.conf;
    ".config/ghostty/config".source = ./../ghostty.conf;
    ".config/commandline_thing/config.yaml".source = ./../commandline_thing.yaml;
    ".config/jjui/config.toml".source = ./../jjui_config.toml;
    ".config/opencode/opencode.jsonc" = lib.mkIf (builtins.pathExists ./../opencode.jsonc) {
      source = ./../opencode.jsonc;
      force = true;
    };
    ".config/jj/config.toml".source = pkgs.writeText "jj-config.toml" (
      (builtins.readFile ./../jj_config.toml)
      + ''

        [user]
        name = "${gitUserName}"
        email = "${gitUserEmail}"
      ''
    );
    # Claude Code settings, managed declaratively (force-overwrites any existing
    # file). Edit these values here rather than via /config - this is a
    # read-only link into the nix store. The Notification hook fires
    # claude-notify-hook when Claude needs input (tmux auto-switch + macOS
    # notification); see the claudeNotifyHook definition above.
    ".claude/settings.json" = {
      force = true;
      text = builtins.toJSON {
        model = "opus";
        enabledPlugins = {
          "swift-lsp@claude-plugins-official" = true;
        };
        tui = "fullscreen";
        hooks.Notification = [
          {
            matcher = "";
            hooks = [
              {
                type = "command";
                command = "${claudeNotifyHook}/bin/claude-notify-hook";
              }
            ];
          }
        ];
      };
    };
  }
  // builtins.listToAttrs (
    map (f: {
      name = f.target;
      value = {
        source = f.source;
      };
    }) customFiles
  )
  // lib.optionalAttrs hasNixAccessTokens {
    # Per-user Nix config. Merged on top of /etc/nix/nix.conf (Determinate Nix).
    # Provides access-tokens so Nix's HTTP fetcher can pull from private hosts
    # via fetchFromGitHub / flake inputs.
    ".config/nix/nix.conf".text = ''
      access-tokens = ${accessTokensValue}
    '';
  }
  // lib.optionalAttrs hasNpmConfig {
    # Per-user npm config. One <scope>:registry=<url> line per entry plus
    # //<host>/:_authToken=<token> per unique registry url.
    ".npmrc".text = npmrcText;
  };

  # Imperative `npm install -g` per entry in globalNpmPackages, into
  # $HOME/.local (user-writable - nix-store npm prefix is read-only).
  # Auth flows through ~/.npmrc generated above. Runs after writeBoundary
  # so .npmrc symlink is in place. `customPathAdditions` should include
  # "$HOME/.local/bin" for the binaries to be discoverable.
  home.activation = lib.optionalAttrs hasGlobalNpmPackages {
    installGlobalNpmPackages = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      # Postinstall scripts (e.g. unrs-resolver) need `node` on PATH;
      # $HOME/.local/bin lets later packages see binaries from earlier ones.
      export PATH="$HOME/.local/bin:${pkgs.nodejs_24}/bin:$PATH"
      $DRY_RUN_CMD mkdir -p "$HOME/.local"
      ${lib.concatMapStringsSep "\n" (
        pkg:
        ''$DRY_RUN_CMD ${pkgs.nodejs_24}/bin/npm install --no-fund --no-audit -g --prefix="$HOME/.local" ${lib.escapeShellArg pkg}''
      ) globalNpmPackages}
    '';
  };

  # WindowThing is a menubar agent, so it wants to be running at login. Pointing
  # launchd at the binary inside the bundle (rather than at the bare executable)
  # is what gives the process its bundle identity: Info.plist, LSUIElement, and
  # the code signature macOS matches the Accessibility grant against.
  #
  # KeepAlive is off on purpose — quitting from the menubar should quit it, not
  # have launchd immediately bring it back.
  launchd.agents.window-thing = {
    enable = true;
    config = {
      ProgramArguments = [ "${windowThingApp}/Contents/MacOS/WindowThing" ];
      RunAtLoad = true;
      KeepAlive = false;
      ProcessType = "Interactive";
    };
  };

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
      windowThing
      git
      tmux
      ghostty-bin
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
      alerter
      claudeNotifyHook
    ]
    ++ customPackages
    # globalNpmPackages install CLIs with `#!/usr/bin/env node` shebangs, so
    # they need node on PATH at runtime (the installer only has it internally).
    ++ lib.optional hasGlobalNpmPackages nodejs_24
    ++ lib.optionals stdenv.isDarwin [ ];
}
