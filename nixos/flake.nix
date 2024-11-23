{
  inputs.nixpkgs.url = github:NixOS/nixpkgs/nixos-unstable;
  inputs.home-manager = {
    url = github:nix-community/home-manager;
    inputs.nixpkgs.follows = "nixpkgs";
  };

  # Reference an external flake
  inputs.commandline_thing.url = github:pj/commandline_thing?ref=1.0.3;
  inputs.plasma-manager = {
    url = "github:nix-community/plasma-manager";
    inputs.nixpkgs.follows = "nixpkgs";
    inputs.home-manager.follows = "home-manager";
  };

  inputs.xremap-flake.url = "github:xremap/nix-flake";

  outputs = { self, nixpkgs, home-manager, plasma-manager, xremap-flake, ... }@inputs: {
    nixosConfigurations.nixbox = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";

      # specialArgs = { inherit inputs; };
      modules = [
        # inputs.xremap-flake.nixosModules.default
        # {
        #   services.xremap.withKDE = true;
        #   services.xremap.config.keymap = [
        #     {
        #       name = "Remap control paste";
        #       remap = { "C-u" = "PAGEUP"; };
        #     }
        #   ];
        # }
        ./nixbox/configuration.nix
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.sharedModules = [ 
            xremap-flake.homeManagerModules.default 
            plasma-manager.homeManagerModules.plasma-manager ];

          home-manager.backupFileExtension = "home_manager_backup";
          home-manager.users.paul = import ./nixbox/home.nix;
          home-manager.extraSpecialArgs = { inherit inputs; };
        }
      ];
    };
  };
}
