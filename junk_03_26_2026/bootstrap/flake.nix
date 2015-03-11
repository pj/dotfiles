{
  description = "Flake for bootstrap dev environment";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    # flake-utils.lib.eachDefaultSystem (system:
        # let
        #     pkgs = nixpkgs.legacyPackages.${system};
        #     deps = with pkgs; [
        #         kubectl
        #         kubernetes-helm
        #         (google-cloud-sdk.withExtraComponents ([pkgs.google-cloud-sdk.components.gke-gcloud-auth-plugin]))
        #         terraform
        #         go
        #         cue
        #         devspace
        #         postgresql_13
        #         nodejs-16_x
        #         jq
        #     ];
        # in {
        #     packages = deps;
        #     devShell = pkgs.mkShell { buildInputs = deps; };
        # }

        let 
          pkgs = nixpkgs.legacyPackages.aarch64-darwin;
          deps = rec {
            go = pkgs.go;
            jq = pkgs.jq;
            delve = pkgs.delve;
            gopls = pkgs.gopls;
            go-tools = pkgs.go-tools;
            default = go;
          };

        in
        {
          packages.aarch64-darwin = deps;
          devShells.aarch64-darwin.default = pkgs.mkShell { packages = pkgs.lib.attrsets.attrValues deps; };
        };
    # );
}
