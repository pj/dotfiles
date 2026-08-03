{
  description = "Example consumer of pj's dotfiles library.";

  # This flake demonstrates how to build a nix-darwin system using the
  # dotfiles library, including how to bring in your own private inputs
  # (e.g. work repos) and per-machine configuration.
  #
  # To adapt this template:
  #   1. Copy this whole `example/` directory somewhere private (e.g. a
  #      new private git repo).
  #   2. Change `dotfiles.url` from `path:../` to
  #      `github:pj/dotfiles?dir=nix` (or your fork).
  #   3. Add any private inputs your machine needs.
  #   4. Fill in `systems.<hostname>` with your machine config.
  #   5. `nix flake update && sudo darwin-rebuild switch --flake .`
  inputs = {
    # For real use: dotfiles.url = "github:pj/dotfiles?dir=nix";
    dotfiles.url = "path:../";

    # Follow dotfiles' nixpkgs to avoid pulling in a second copy.
    nixpkgs.follows = "dotfiles/nixpkgs";

    # Private inputs live here, alongside dotfiles.
    #
    # Example — a private repo fetched over SSH. Under `sudo darwin-rebuild`,
    # nix reuses the flake.lock-locked source from /nix/store without
    # re-fetching, so SSH keys are only needed at `nix flake update` time.
    #
    # my-private-tool = {
    #   url = "git+ssh://git@github.com/my-org/my-private-tool?ref=main";
    #   flake = false;
    # };
  };

  outputs =
    inputs@{ self, dotfiles, ... }:
    dotfiles.lib.mkOutputs {
      inherit inputs self;
      systems = {
        "example-host" =
          let
            pkgs = import inputs.nixpkgs {
              system = "aarch64-darwin";
              config.allowUnfree = true;
            };
            # Example custom derivation using a private flake input:
            #
            # my-tool = pkgs.stdenv.mkDerivation {
            #   pname = "my-tool";
            #   version = "1.0.0";
            #   src = inputs.my-private-tool;
            #   installPhase = "cp -r . $out";
            # };
          in
          {
            username = "you";
            platform = "aarch64-darwin";
            gitUserName = "Your Name";
            gitUserEmail = "you@example.com";

            # Shell environment variables (exported via home-manager sessionVariables).
            environmentVariables = { };

            # Nix HTTP fetcher access tokens (host -> token). Lands in
            # ~/.config/nix/nix.conf. Useful for private fetchFromGitHub.
            nixAccessTokens = { };

            # Per-scope npm registry config. Generates ~/.npmrc.
            npmScopedRegistries = { };

            # Global npm packages, installed via
            # `npm install -g --prefix=$HOME/.local` on every activation.
            globalNpmPackages = [ ];

            customSystemSettings = { };
            customPathAdditions = [ "$HOME/.local/bin" ];
            customPackages = with pkgs; [
              # Add packages here.
              # my-tool
            ];
            customFiles = [ ];
          };
      };
    };
}
