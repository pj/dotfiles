# Machine-specific configuration (gitignored).
# Edit this file for work-specific packages, homebrew casks, paths, etc.

{
  nixpkgs ? null,
}:

let
  getPkgs =
    platform:
    import nixpkgs {
      system = platform;
      config.allowUnfree = true;
    };

  # Load a local flake by path if it exists, returning null otherwise.
  # Usage: tryFlake "/absolute/path/to/project"
  tryFlake = path: if builtins.pathExists path then builtins.getFlake ("path:" + path) else null;

in
{
  systems = {
    "Pauls-MacBook-Air" =
      let
        pkgs = getPkgs "aarch64-darwin";
      in
      {
        username = "pauljohnson";
        platform = "aarch64-darwin";
        gitUserName = "Paul Johnson";
        gitUserEmail = "paul@johnson.kiwi.nz";
        customSystemSettings = {
          homebrew = {
            enable = true;
            onActivation = {
              autoUpdate = true;
              cleanup = "zap";
            };
            global = {
              brewfile = true;
            };
            brews = [
              "specify"
            ];
            casks = [
              "1password"
              "1password-cli"
            ];
          };
        };
        customPathAdditions = [
          "/opt/homebrew/bin"
          "$HOME/.local/bin"
        ];
        globalNpmPackages = [
          "paperclipai"
        ];
        customPackages = with pkgs; [
          ffmpeg_6-full
          gallery-dl
          fdupes
          claude-code
          tart
          packer
          sshpass
          gh
          git-filter-repo
          ghostty-bin
          just
          xcodegen
          xcbeautify
          pwgen
        ];
        customFiles = [ ];
      };
  };
}
