{
  description = "Example nix-darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:nix-darwin/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    commandline_thing.url = "github:pj/commandline_thing?ref=1.0.3";
    emojifont.url = "github:pj/emojifont";
    memeterminal.url = "github:pj/iTerm2?ref=memeterminal";
  };

  outputs =
    {
      self,
      nix-darwin,
      nixpkgs,
      home-manager,
      commandline_thing,
      memeterminal,
      ...
    }@inputs:
    let
      # Machine-specific config (hostnames, work packages, homebrew, etc.) from gitignored local.nix.
      # Copy local.nix.example to local.nix and customize.
      systems = (import ./local.nix { nixpkgs = nixpkgs; }).systems;

      # Helper function to create a darwin configuration for a given hostname and system config attrset
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

                # xcodebuild/SPM use NSHomeDirectory() which returns /var/empty
                # for nixbld users. Create writable dirs so nix builds of
                # Xcode projects (e.g. MemeTerminal) work.
                system.activationScripts.postActivation.text = ''
                  mkdir -p /var/empty/Library/Developer/Xcode/DerivedData
                  mkdir -p /var/empty/Library/Developer/CoreSimulator/Devices
                  mkdir -p /var/empty/Library/Caches/org.swift.swiftpm
                  chgrp -R nixbld /var/empty/Library 2>/dev/null || true
                  chmod -R g+rwx /var/empty/Library 2>/dev/null || true
                '';

                fonts.packages = [
                  ./MonacoNerdFontCompleteMono.ttf
                  # MemeFont: Monaco Nerd Font with meme images injected as SBIX
                  # color emoji at U+F900+ (see github:pj/emojifont)
                  (pkgs.runCommand "memefont"
                    {
                      nativeBuildInputs = [ inputs.emojifont.packages.${platform}.default ];
                    }
                    ''
                      mkdir -p $out/share/fonts/truetype
                      emojifont "${./MonacoNerdFontCompleteMono.ttf}" \
                        $out/share/fonts/truetype/MemeFont.ttf \
                        --mappings "U+F900:${./memes/pepe.jpg},U+F901:${./memes/mofusand_shark.jpg}" \
                        --font-name "MemeFont"
                    ''
                  )
                ];
              }
            )
            home-manager.darwinModules.home-manager
            {
              nixpkgs.config.allowUnfree = true;
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.${username} = import ./home-manager/home.nix {
                inherit
                  commandline_thing
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

      # Create darwinConfigurations for each system
      darwinConfigurations = nixpkgs.lib.mapAttrs mkDarwinSystem systems;
    in
    {
      inherit darwinConfigurations;

      # Expose the package set for the first system (or use a specific one)
      darwinPackages = (builtins.head (builtins.attrValues darwinConfigurations)).pkgs;
    };
}
