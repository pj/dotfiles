# Reusable nix-darwin flake outputs builder.
#
# Takes the flake's `inputs` attrset plus a `systems` config (hostname ->
# per-machine attrs), and returns the standard `{ darwinConfigurations,
# darwinPackages }` outputs.
#
# Called from a machine-specific flake.nix (gitignored). This file stays
# committed and is the reusable "shape" of any nix-darwin system.
#
# Expected `systems.<hostname>` schema:
#   username, platform                              (required)
#   gitUserName, gitUserEmail                       (default: "Unknown"/"unknown@example.com")
#   customSystemSettings                            (default: {})    - e.g. { homebrew = { ... }; }
#   customPackages, customPathAdditions             (default: [])
#   customFiles                                     (default: [])    - list of {source, target}
#   environmentVariables, nixAccessTokens           (default: {})
#   npmScopedRegistries                             (default: {})
#   globalNpmPackages                               (default: [])
#
# `flakeRoot` should be the flake.nix's directory (usually `./.` from
# flake.nix) so this module can locate ./MonacoNerdFontCompleteMono.ttf,
# ./memes/, ./home-manager/home.nix, etc.

{
  inputs,
  self,
  flakeRoot,
}:
{ systems }:
let
  inherit (inputs)
    nix-darwin
    nixpkgs
    home-manager
    commandline_thing
    memeterminal
    window_thing
    ;

  mkDarwinSystem =
    hostname:
    {
      username,
      platform,
      gitUserName ? "Unknown",
      gitUserEmail ? "unknown@example.com",
      customSystemSettings ? { },
      customPackages ? [ ],
      customPathAdditions ? [ ],
      customFiles ? [ ],
      environmentVariables ? { },
      nixAccessTokens ? { },
      npmScopedRegistries ? { },
      globalNpmPackages ? [ ],
    }:
    nix-darwin.lib.darwinSystem {
      specialArgs = { };
      modules = [
        (
          { pkgs, ... }:
          {
            # Allow unfree packages (e.g., vault with BSL license)
            nixpkgs.config.allowUnfree = true;

            homebrew = customSystemSettings.homebrew or { };

            # List packages installed in system profile. To search by name, run:
            # $ nix-env -qaP | grep wget
            environment.systemPackages = [
              inputs.memeterminal.packages.${platform}.default
            ];

            # Necessary for using flakes on this system.
            nix.settings.experimental-features = "nix-command flakes";

            nix.settings.trusted-users = [ "root" username ];
            nix.enable = false;
            # Enable alternative shell support in nix-darwin.
            # programs.zsh.enable = true;

            # Set Git commit hash for darwin-version.
            system.configurationRevision = self.rev or self.dirtyRev or null;

            # Used for backwards compatibility, please read the changelog before changing.
            # $ darwin-rebuild changelog
            system.stateVersion = 5;

            # The platform the configuration will be used on.
            nixpkgs.hostPlatform = platform;

            # Set hostname
            networking.hostName = hostname;

            # Set user home directory
            users.users.${username}.home = "/Users/${username}";

            # Set primary user (required for launchd.user.agents)
            system.primaryUser = username;

            fonts.packages = [
              (flakeRoot + "/MonacoNerdFontCompleteMono.ttf")
              (pkgs.stdenv.mkDerivation {
                pname = "MemeFont";
                version = "0.0.0";
                dontUnpack = true;
                nativeBuildInputs = [ inputs.emojifont.packages.${platform}.default ];
                # Bakes in dotfiles/nix/memes/ and MonacoNerdFontCompleteMono.ttf as
                # build inputs — MemeFont.ttf is rebuilt from source on every nix
                # build rather than living as a committed binary. Code-point
                # assignment (sorted stem -> U+100000 + index) is emojifont's, see
                # build_meme_mappings_from_dir in inject.py — commandline_thing's
                # MemeCodepoint replicates the same rule over the same directory.
                buildPhase = ''
                  runHook preBuild
                  emojifont-build-meme-font ${./MonacoNerdFontCompleteMono.ttf} ${./memes} MemeFont.ttf --font-name MemeFont
                  runHook postBuild
                '';
                installPhase = ''
                  runHook preInstall
                    mkdir -p $out/share/fonts/truetype
                  cp MemeFont.ttf $out/share/fonts/truetype/MemeFont.ttf
                  runHook postInstall
                '';
              })
            #   (pkgs.runCommand "memefont"
            #     {
            #       nativeBuildInputs = [ inputs.emojifont.packages.${platform}.default ];
            #     }
            #     ''
            #       mkdir -p $out/share/fonts/truetype
            #       emojifont "${flakeRoot + "/MonacoNerdFontCompleteMono.ttf"}" \
            #         $out/share/fonts/truetype/MemeFont.ttf \
            #         --mappings "U+F900:${flakeRoot + "/memes/pepe.jpg"},U+F901:${
            #           flakeRoot + "/memes/mofusand_shark.jpg"
            #         }" \
            #         --font-name "MemeFont"
            #     ''
            #   )
            ];
          }
        )
        home-manager.darwinModules.home-manager
        {
          nixpkgs.config.allowUnfree = true;
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.${username} = import (flakeRoot + "/home-manager/home.nix") {
            inherit
              commandline_thing
              window_thing
              customPackages
              customPathAdditions
              customFiles
              gitUserName
              gitUserEmail
              environmentVariables
              nixAccessTokens
              npmScopedRegistries
              globalNpmPackages
              ;
          };
        }
      ];
    };

  darwinConfigurations = nixpkgs.lib.mapAttrs mkDarwinSystem systems;
in
{
  inherit darwinConfigurations;

  # Expose the package set for the first system (or use a specific one)
  darwinPackages = (builtins.head (builtins.attrValues darwinConfigurations)).pkgs;
}
