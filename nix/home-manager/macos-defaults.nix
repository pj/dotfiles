# macOS settings that differ from Apple's factory defaults.
# Generated from `defaults read` on 2026-04-17.
#
# These are shared across all machines.
# Import in home.nix:  imports = [ ./macos-defaults.nix ];
# Apply with: darwin-rebuild switch
#
# See macos-defaults-reference.nix for the full catalogue of options.
{ lib, ... }:
{
  targets.darwin.defaults = {

    # ------------------------------------------------------------------
    # NSGlobalDomain — system-wide preferences
    # ------------------------------------------------------------------
    NSGlobalDomain = {

      # Dark mode.  Remove this key (or set to null) for Light mode.
      # Default: Light (key absent)
      AppleInterfaceStyle = "Dark";

      # Auto-hide the menu bar on the desktop.
      # 0 = never auto-hide, 1 = auto-hide
      # Default: 0
      "_HIHideMenuBar" = 1;

      # Keep the menu bar visible inside full-screen applications.
      # Default: 0 (menu bar hides in full-screen)
      AppleMenuBarVisibleInFullscreen = 1;

      # Scroll direction.
      # true  = "natural" (content tracks finger direction)
      # false = traditional (scroll bar tracks finger direction)
      # Default: true
      "com.apple.swipescrolldirection" = false;

      # Custom keyboard shortcuts for menu items.
      # Modifier keys:  @ = Cmd, ^ = Ctrl, ~ = Option, $ = Shift
      # Example: "@^l" = Ctrl+Cmd+L
      # Note: the string must match the exact menu item title.
      NSUserKeyEquivalents = {
        # Lock Screen (Apple menu) — remapped from default Ctrl+Cmd+Q
        "Lock Screen" = "@^l";
      };
    };

    # ------------------------------------------------------------------
    # Dock
    # ------------------------------------------------------------------
    "com.apple.dock" = {

      # Automatically hide and show the Dock.
      # Default: false
      autohide = true;

      # Icon size in pixels.
      # Default: 48
      tilesize = 128;

      # Hot corner — bottom-right.
      #  0 = no action       5 = start screen saver   11 = Launchpad
      #  2 = Mission Control  6 = disable screen saver 12 = Notification Center
      #  3 = App Exposé      10 = put display to sleep 13 = Lock Screen
      #  4 = Desktop                                    14 = Quick Note
      # Default: 0 (no action)
      "wvous-br-corner" = 14;
    };

    # ------------------------------------------------------------------
    # Finder
    # ------------------------------------------------------------------
    "com.apple.finder" = {

      # Default view style for new Finder windows.
      # "icnv" = Icon, "Nlsv" = List, "clmv" = Column, "glyv" = Gallery
      # Default: "icnv"
      FXPreferredViewStyle = "Nlsv";
    };

    # ------------------------------------------------------------------
    # Menu bar clock
    # ------------------------------------------------------------------
    "com.apple.menuextra.clock" = {

      # Show date in the menu bar clock.
      # 0 = when space allows, 1 = always, 2 = never
      # Default: 1
      ShowDate = 0;
    };

    # ------------------------------------------------------------------
    # Window Manager (tiling / Stage Manager)
    # ------------------------------------------------------------------
    "com.apple.WindowManager" = {

      # Margins (gaps) around tiled/snapped windows.
      # true = show margins, false = no margins (windows touch edges)
      # Default: true (margins enabled)
      EnableTiledWindowMargins = 0;

      # Click wallpaper to reveal desktop.
      # false = always reveal, true = only in Stage Manager
      # Default: false (always reveal)  [macOS Sonoma+]
      HideDesktop = 1;
    };

    # ------------------------------------------------------------------
    # Advertising / Privacy
    # ------------------------------------------------------------------
    "com.apple.AdLib" = {

      # Apple personalised advertising.
      # Default: true
      allowApplePersonalizedAdvertising = false;
    };
  };
}
