{
  inputs.nixpkgs.url = github:NixOS/nixpkgs/nixos-24.05;
  inputs.home-manager.url = github:nix-community/home-manager?ref=release-24.05;

  # Reference an external flake
  inputs.commandline_thing.url = github:pj/commandline_thing?ref=1.0.3;

  outputs = { self, nixpkgs, ... }@inputs: {
    nixosConfigurations.nixbox = nixpkgs.lib.nixosSystem {
      specialArgs = { inherit inputs; };
      modules = [ ./nixbox/configuration.nix ];
    };
  };
}