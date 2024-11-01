{
  inputs.nixpkgs.url = github:NixOS/nixpkgs/nixos-24.05;
  inputs.home-manager.url = github:nix-community/home-manager?ref=release-24.05;


  outputs = { self, nixpkgs, ... }@inputs: {
    nixosConfigurations.nixbox = nixpkgs.lib.nixosSystem {
      specialArgs = { inherit inputs; };
      modules = [ ./nixbox/configuration.nix ];
    };
  };
}