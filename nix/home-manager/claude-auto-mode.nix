# Auto-mode classifier configuration for Claude Code, merged into
# ~/.claude/settings.json by home.nix as the `autoMode` block.
#
# WHY THIS FILE EXISTS
#   `/auto-mode-setup` inside Claude Code normally writes this section itself,
#   after scanning your shell history and repos. It cannot here: home.nix
#   installs ~/.claude/settings.json with `force = true`, so the file is a
#   read-only symlink into the nix store and the wizard fails with
#   "Could not write /Users/<you>/.claude/settings.json". Keeping the answers
#   here instead makes them declarative and portable to another machine, which
#   is the same trade already made for `model`, `tui` and the hooks.
#
# THESE LISTS REPLACE THE DEFAULTS, THEY DO NOT MERGE INTO THEM
#   This is the trap in this file. Setting `autoMode.soft_deny` to a two-element
#   list does not add two rules — it leaves the classifier with two rules and
#   drops the other 66. Verified: with a bare two-rule list,
#   `claude auto-mode config` reported `soft_deny: 2`, not 68.
#
#   So both lists below are built as *snapshot + change*, against
#   ./claude-auto-mode-defaults.json — a verbatim capture of
#   `claude auto-mode defaults`. `allow` and `hard_deny` are deliberately never
#   set, because omitting a key is what leaves its shipped defaults alone.
#
# REFRESHING THE SNAPSHOT
#   The snapshot pins Anthropic's wording as of Claude Code 2.1.233. After a
#   Claude Code upgrade, re-capture it and rebuild:
#
#     claude auto-mode defaults > ~/dotfiles/nix/home-manager/claude-auto-mode-defaults.json
#
#   Only the seven entries named in `environmentOverrides` are ours; everything
#   else is picked up from the snapshot automatically, so a refresh is safe.
#   If Anthropic renames one of those seven headings, evaluation fails with a
#   loud message rather than silently dropping the customisation.
#
# CHECKING IT
#   claude auto-mode config     # effective config: these values where set, defaults otherwise
#   claude auto-mode defaults   # the shipped baseline, for diffing
#   claude auto-mode critique   # AI review of the custom rules below
{ lib }:

let
  defaults = builtins.fromJSON (builtins.readFile ./claude-auto-mode-defaults.json);

  # Facts about this machine and its trust boundary, keyed by the bold heading
  # each default entry starts with. The classifier reads these when deciding
  # whether an action is in scope. Entries not named here keep the shipped
  # wording — mostly "None configured", which is accurate for a personal Mac.
  environmentOverrides = {
    "Organization" = ''
      **Organization**: None — personal machine, personal projects. No employer,
      tenant or internal estate is in scope here.
    '';

    "Primary use of Claude Code" = ''
      **Primary use of Claude Code**: software development — macOS apps in Swift
      (Swift Package Manager, AppKit/SwiftUI, the Xcode toolchain) and this
      Nix / nix-darwin / home-manager dotfiles repo.
    '';

    "Secrets management" = ''
      **Secrets management**: 1Password (the `op` CLI) and the macOS login
      Keychain. The Keychain holds the Apple Developer signing identity, the
      `xcrun notarytool` credential profiles and the Sparkle EdDSA
      release-signing key, reached through `security` and `notarytool`. There is
      no vault service, and no secrets are committed — `nixAccessTokens` and npm
      tokens are injected per host, never stored in the repo.
    '';

    "CI/CD deploy targets" = ''
      **CI/CD deploy targets**: GitHub Releases under `github.com/pj/*`,
      published by `scripts/release.sh` through the `gh` CLI, together with the
      Sparkle `appcast.xml` served from those repos. Publishing a release is
      public and effectively irreversible — installed copies auto-update from
      it. There are no servers, clusters or cloud environments to deploy to.
    '';

    "Network posture" = ''
      **Network posture**: a single developer Mac. The only private hosts are
      local Tart VMs on 192.168.64.0/24, reached over SSH as the `admin` user
      for tests and screenshots; those VMs are disposable and ship with SIP
      disabled by design, so that is expected there and nowhere else.
      Everything beyond them is the public internet.
    '';

    "Source control" = ''
      **Source control**: GitHub under `github.com/pj` (personal).
      `github.com/pj/window-thing` and `github.com/pj/dotfiles` are both public
      — anything pushed to them is published. Treat any other repo as private
      until its visibility has actually been checked. Repositories are
      colocated jujutsu + git, so `jj` commands are ordinary source control
      here rather than an unusual tool.
    '';

    "Sensitive data locations & audiences" = ''
      **Sensitive data locations & audiences**: any file or store holding
      personal data, confidential business data, credentials, regulated data, or
      similarly sensitive material; preserve exact handles when known and share
      only with audiences cleared at the [named+specifics] bar. On this machine
      that specifically includes the macOS login Keychain, `~/.ssh`,
      `~/.zsh_history` and terminal scrollback — an Apple ID password and an
      app-specific password have been typed at this terminal — and any `.env` or
      per-host Nix file carrying access tokens.
    '';
  };

  # Extra BLOCK rules, appended to the shipped soft_deny set. Both come from
  # incidents in the window_thing repo rather than from theory: each one
  # describes something that actually went wrong and cost the user something.
  extraSoftDeny = [
    ''
      Host-vs-VM Test Isolation: In the window_thing repo, running the
      window-moving suites on this Mac instead of inside the Tart VM — that
      means `swift test` without `--skip IntegrationTests
      --skip PrimaryDisplayLayoutTests`, or invoking `vm/scripts/ui-test.sh` or
      `ui-lib.sh` locally. They move the user's real windows and take over the
      screen mid-session; the user has asked more than once that they run in the
      VM (`./vm/run-tests.sh`) instead. Running the pure suites locally with
      those two skips is fine, and so is reading any of these files.
    ''
    ''
      WindowThing Live Config: Writing to
      `~/Library/Application Support/WindowThing/config.yaml` from a test, a
      fixture, or a view model constructed with no arguments — the no-argument
      initialiser resolves to the real `ConfigManager.shared` and persists to
      the user's own file. A test run once overwrote the user's saved layouts,
      two of which were unrecoverable. Tests must inject mocks; reading the file
      is fine.
    ''
  ];

  # Entries are single long lines; the ''-strings above are written as wrapped
  # paragraphs so they can be reviewed, so fold them back before handing over.
  unwrap =
    s: lib.concatStringsSep " " (lib.filter (x: x != "") (lib.splitString "\n" (lib.trim s)));

  headingOf =
    entry:
    lib.findFirst (k: lib.hasPrefix "**${k}**" entry) null (builtins.attrNames environmentOverrides);

  environment = map (
    entry:
    let
      heading = headingOf entry;
    in
    if heading == null then entry else unwrap environmentOverrides.${heading}
  ) defaults.environment;

  # Which override headings actually matched a snapshot entry. A miss means
  # Anthropic reworded that heading and our text silently stopped applying, so
  # fail the build rather than ship a config that quietly lost a customisation.
  matched = lib.filter (k: lib.any (e: lib.hasPrefix "**${k}**" e) defaults.environment) (
    builtins.attrNames environmentOverrides
  );
  missing = lib.subtractLists matched (builtins.attrNames environmentOverrides);
in
assert lib.assertMsg (missing == [ ]) ''
  claude-auto-mode.nix: no entry in claude-auto-mode-defaults.json starts with
  ${lib.concatMapStringsSep ", " (k: "**${k}**") missing}.
  The shipped environment headings have changed. Re-capture the snapshot with
  `claude auto-mode defaults > claude-auto-mode-defaults.json`, then rename the
  affected keys in environmentOverrides to match.
'';
{
  inherit environment;
  soft_deny = defaults.soft_deny ++ (map unwrap extraSoftDeny);
}
