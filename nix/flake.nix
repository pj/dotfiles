{
  description = "pj's dotfiles library — reusable nix-darwin machinery.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:nix-darwin/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    commandline_thing.url = "github:pj/commandline_thing?ref=1.0.9";
    # Pinned to a tag rather than a branch: that tag's flake.nix carries the
    # hash of its own signed release asset, which is what actually gets
    # installed. See window-thing's RELEASE.md.
    window_thing.url = "github:pj/window-thing?ref=v0.2.0";
    emojifont.url = "github:pj/emojifont";
    memeterminal.url = "github:pj/iTerm2?ref=memeterminal";
  };

  outputs =
    dotfilesInputs@{ self, ... }:
    {
      # Library entry point. Downstream (consumer) flakes call this with:
      #   - inputs:  their own inputs attrset (base + any private inputs)
      #   - self:    the consumer's `self` (used for system.configurationRevision)
      #   - systems: hostname -> per-machine config attrs
      #
      # This flake's own inputs (nixpkgs, nix-darwin, home-manager, etc.)
      # are merged under the consumer's inputs so the consumer wins on any
      # collision. Consumers typically use `nixpkgs.follows = "dotfiles/nixpkgs"`
      # to avoid duplication.
      #
      # See `./example/flake.nix` for a full working consumer template.
      lib.mkOutputs =
        { inputs, self, systems }:
        import ./flake-lib.nix {
          inputs = dotfilesInputs // inputs;
          inherit self;
          flakeRoot = ./.;
        } { inherit systems; };
    };
}
