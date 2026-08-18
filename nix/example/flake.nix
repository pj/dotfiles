{
  description = "Example consumer of pj's dotfiles library.";

  # This flake is a template for a private, per-machine nix-darwin config
  # built on top of pj's dotfiles library. Everything below is a working
  # example: copy this whole `example/` directory to a private git repo,
  # replace the placeholders, and run `sudo darwin-rebuild switch --flake .`.
  #
  # Layout:
  #   inputs:  dotfiles + follows nixpkgs; optional private repos.
  #   outputs: single call to `dotfiles.lib.mkOutputs` with a
  #            per-hostname `systems` attrset.
  #
  # To adapt this template:
  #   1. Copy this whole `example/` directory somewhere private (e.g. a
  #      new private git repo).
  #   2. Change `dotfiles.url` from `path:../` to
  #      `github:pj/dotfiles?dir=nix` (or your fork).
  #   3. Add any private inputs your machine needs.
  #   4. Fill in `systems.<hostname>` with your machine config.
  #   5. `nix flake update && sudo darwin-rebuild switch --flake .`
  #
  # Common workflows:
  #
  #   Update dotfiles from github, then rebuild:
  #     nix flake update dotfiles && sudo darwin-rebuild switch --flake .
  #
  #   Test unpushed dotfiles changes without committing:
  #     sudo darwin-rebuild switch --flake . \
  #       --override-input dotfiles path:$HOME/dotfiles/nix
  #
  #   Update a private input (e.g. after upstream pushes to main):
  #     nix flake update <input-name> && sudo darwin-rebuild switch --flake .
  #
  # Auth note: `nix flake update <name>` runs under your user (SSH keys
  # available); `sudo darwin-rebuild switch` reads flake.lock and reuses
  # the already-fetched /nix/store output without needing SSH keys under
  # root.
  inputs = {
    # For real use: dotfiles.url = "github:pj/dotfiles?dir=nix";
    dotfiles.url = "path:../";

    # Follow dotfiles' nixpkgs to avoid pulling in a second copy.
    nixpkgs.follows = "dotfiles/nixpkgs";

    # Private inputs live alongside dotfiles. Two patterns:
    #
    # 1) A source-only repo pulled over SSH (no flake.nix inside it).
    #    Perfect for internal CLIs that we wrap with a custom derivation
    #    below.
    #
    # my-private-tool = {
    #   url = "git+ssh://git@github.com/my-org/my-private-tool?ref=main";
    #   flake = false;
    # };
    #
    # 2) A public github repo pinned to a specific ref:
    #
    # some-lib = {
    #   url = "github:some-org/some-lib?ref=v1.2.3";
    #   flake = false;
    # };
  };

  outputs =
    inputs@{ self, dotfiles, ... }:
    dotfiles.lib.mkOutputs {
      inherit inputs self;
      systems = {
        # Hostname; must match `scutil --get LocalHostName`.
        "example-host" =
          let
            pkgs = import inputs.nixpkgs {
              system = "aarch64-darwin";
              config.allowUnfree = true;
            };

            # ---------- Custom derivation examples ------------------
            #
            # Pattern A: fetch a pinned prebuilt binary from a release
            # URL. To bump version: change `version`, set
            # `sha256 = pkgs.lib.fakeSha256`, run `nix build`, and paste
            # the real hash from the error message.
            #
            # kubectlOldFromRelease =
            #   version:
            #   let
            #     arch = if pkgs.stdenv.isAarch64 then "arm64" else "amd64";
            #     url = "https://dl.k8s.io/release/${version}/bin/darwin/${arch}/kubectl";
            #   in
            #   pkgs.stdenv.mkDerivation {
            #     pname = "kubectl-old";
            #     inherit version;
            #     src = pkgs.fetchurl {
            #       inherit url;
            #       sha256 = pkgs.lib.fakeSha256;
            #     };
            #     dontUnpack = true;
            #     installPhase = ''
            #       mkdir -p $out/bin
            #       cp $src $out/bin/old_kubectl
            #       chmod +x $out/bin/old_kubectl
            #     '';
            #   };
            # kubectlOld = kubectlOldFromRelease "v1.21.14";
            #
            # Pattern B: build a Python CLI from a private flake input.
            # Requires the private input declared above with
            # `flake = false`. Copies the source into a venv and wraps
            # entry points with a small shim so they're on PATH.
            #
            # myToolPython = pkgs.python311;
            # my-private-tool = pkgs.stdenv.mkDerivation {
            #   pname = "my-private-tool";
            #   version = "1.0.0";
            #   src = inputs.my-private-tool;
            #   nativeBuildInputs = [ myToolPython ];
            #   dontBuild = true;
            #   # pip venv shebangs get rewritten by nix's fixup; skip it.
            #   dontFixup = true;
            #   installPhase = ''
            #     runHook preInstall
            #     export HOME=$TMPDIR
            #     venv=$out/libexec/my-private-tool/venv
            #     mkdir -p $out/libexec/my-private-tool $out/bin
            #     ${myToolPython}/bin/python -m venv $venv
            #     $venv/bin/pip install --no-cache-dir --disable-pip-version-check .
            #
            #     # Thin wrapper on PATH. Setting sys.argv[0] makes click
            #     # and similar libraries show the right name in --help.
            #     cat > $out/bin/my-tool <<PYEOF
            #     #!$venv/bin/python
            #     import sys
            #     sys.argv[0] = "my-tool"
            #     from my_tool.cli import main
            #     sys.exit(main())
            #     PYEOF
            #     chmod +x $out/bin/my-tool
            #     runHook postInstall
            #   '';
            # };
          in
          {
            # ---------- Required identity ---------------------------
            username = "you";
            platform = "aarch64-darwin";
            gitUserName = "Your Name";
            gitUserEmail = "you@example.com";

            # ---------- Shell environment variables -----------------
            # Passed to home-manager sessionVariables, which lands in
            # hm-session-vars.sh. That file is sourced from .zshenv, so
            # these are set on every shell startup.
            #
            # Use this instead of `~/.zshrc.local` — the library does
            # not source that file.
            environmentVariables = {
              # AWS_PROFILE = "your-aws-profile";
              # AWS_REGION = "us-east-1";
              # KUBECONFIG = "$HOME/.kube/config";
            };

            # ---------- Nix HTTP fetcher access tokens --------------
            # host -> token, joined into a single `access-tokens = ...`
            # line in ~/.config/nix/nix.conf. Lets Nix's HTTP fetcher
            # pull from private repos via fetchFromGitHub / flake inputs
            # over HTTPS. Prefer SSH for private flake inputs (see
            # `inputs` above); this is for the fetcher itself.
            nixAccessTokens = {
              # "github.com" = "ghp_yourTokenHere";
            };

            # ---------- Per-scope npm registry auth -----------------
            # Generates ~/.npmrc with a <scope>:registry=<url> line and
            # a //<host>/:_authToken=<token> line per unique registry.
            # Needed for `npm install` of scoped packages from private
            # registries (e.g. GitHub Packages).
            npmScopedRegistries = {
              # "@your-org" = {
              #   url = "https://npm.pkg.github.com";
              #   authToken = "ghp_yourTokenHere";
              # };
            };

            # ---------- Global npm packages -------------------------
            # Installed on every activation via
            # `npm install -g --prefix=$HOME/.local`. Auth flows through
            # ~/.npmrc above. Pin versions with `pkg@x.y.z`.
            #
            # Note: removing an entry here does NOT auto-uninstall it;
            # run `npm uninstall -g --prefix=$HOME/.local <pkg>`
            # manually. Requires `$HOME/.local/bin` in
            # customPathAdditions.
            globalNpmPackages = [
              # "@your-org/some-cli"
              # "some-public-cli@1.2.3"
            ];

            # ---------- System-level nix-darwin knobs ---------------
            # Passed straight to the darwinSystem module set. For
            # anything outside home-manager scope (Homebrew, launchd,
            # security, defaults).
            customSystemSettings = {
              # Homebrew (opt-in). nix-darwin manages the Brewfile
              # declaratively; brews/casks/taps here become the source
              # of truth. Requires `brew` already installed on the Mac.
              #
              # homebrew = {
              #   enable = true;
              #   onActivation = {
              #     autoUpdate = true;
              #     cleanup = "zap";
              #     # Workaround for nix-darwin#1787: Homebrew/brew#21351
              #     # (Jan 2026) made `brew bundle install --cleanup`
              #     # require explicit confirmation. Drop this once
              #     # nix-darwin#1774 lands and you bump the flake input.
              #     extraFlags = [ "--force-cleanup" ];
              #   };
              #   global = {
              #     brewfile = true;
              #   };
              #   brews = [
              #     # Formulae not (yet) in nixpkgs, or ones you want the
              #     # brew build of (e.g. because it wires into a cask).
              #     # "some-brew"
              #   ];
              #   casks = [
              #     # macOS apps. Install into /Applications; removed
              #     # when dropped here (`cleanup = "zap"`).
              #     # "some-app"
              #   ];
              #   taps = [
              #     # "your-org/homebrew-tap"
              #   ];
              # };
            };

            # ---------- PATH additions ------------------------------
            # Prepended to PATH in .zshrc (via initContent in home.nix)
            # and added to home.sessionPath. Order matters: last entry
            # wins.
            customPathAdditions = [
              "$HOME/.local/bin" # required if using globalNpmPackages
              # "/opt/homebrew/bin"  # add if using homebrew above
            ];

            # ---------- Nixpkgs to install in home.packages ---------
            # Search names with `nix search nixpkgs <name>`.
            customPackages = with pkgs; [
              # Examples — uncomment what you want:
              # vault
              # mosh
              # kubectl
              # k9s
              # awscli2
              # gh
              # jwt-cli
              # terraform
              # pre-commit
              # postgresql_16

              # Custom derivations defined above:
              # kubectlOld
              # my-private-tool
            ];

            # ---------- Static file links (declarative dotfiles) ----
            # { source, target } pairs; target is relative to $HOME.
            customFiles = [
              # {
              #   source = ./configs/some-app.json;
              #   target = "Library/Application Support/SomeApp/config.json";
              # }
            ];
          };
      };
    };
}
