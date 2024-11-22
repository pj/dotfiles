{
  description = "Flake for lazy_test dev environment";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
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
          pkgs = nixpkgs.legacyPackages.${system};
          deps = rec {
            jq = pkgs.jq;
            nodejs_20 = pkgs.nodejs_20;
            default = nodejs_20;
          };

        in
        {
          packages = deps;
          devShell = pkgs.mkShell { packages = pkgs.lib.attrsets.attrValues deps; };
        }
    );
}
