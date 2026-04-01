# ======================================================================
# macOS Defaults — Complete Reference
# ======================================================================
#
# Every option below is commented out with its DEFAULT value and a
# description.  Uncomment and change any value you want, then add
#   imports = [ ./macos-defaults-reference.nix ];
# to your home.nix  (or merge into macos-defaults.nix).
#
# Apply with:  darwin-rebuild switch
#
# Tip: discover a setting's domain/key by running
#   defaults read > /tmp/before.plist
#   <change the setting in System Settings>
#   defaults read > /tmp/after.plist
#   diff /tmp/before.plist /tmp/after.plist
#
# Reference:
#   https://macos-defaults.com
#   https://ss64.com/osx/defaults.html
#   https://daiderd.com/nix-darwin/manual/index.html  (system.defaults.*)
# ======================================================================
{ lib, ... }:
{
  targets.darwin.defaults = {

    # ================================================================
    #  NSGlobalDomain — system-wide preferences
    # ================================================================
    # NSGlobalDomain = {
    #
    #   ## ── Appearance ────────────────────────────────────────────
    #
    #   # Dark / Light mode.
    #   # "Dark" = dark mode.  Remove key or set null for light mode.
    #   # Default: (absent — light mode)
    #   AppleInterfaceStyle = "Dark";
    #
    #   # Auto-switch between light and dark based on time of day.
    #   # Default: false
    #   AppleInterfaceStyleSwitchesAutomatically = false;
    #
    #   # Accent colour.
    #   # -1 = Graphite, 0 = Red, 1 = Orange, 2 = Yellow, 3 = Green,
    #   #  4 = Blue (default), 5 = Purple, 6 = Pink
    #   # Default: (absent — Blue)
    #   AppleAccentColor = 4;
    #
    #   # Highlight colour (selection).
    #   # Space-separated RGB floats, e.g. "0.698039 0.843137 1.0 Blue"
    #   # Default: (absent — system blue)
    #   AppleHighlightColor = "0.698039 0.843137 1.000000 Blue";
    #
    #   ## ── Scrolling / Trackpad ──────────────────────────────────
    #
    #   # Natural (content-tracks-finger) scrolling.
    #   # true = natural, false = traditional
    #   # Default: true
    #   "com.apple.swipescrolldirection" = true;
    #
    #   # Show scroll bars.
    #   # "Automatic", "WhenScrolling", "Always"
    #   # Default: "Automatic"
    #   AppleShowScrollBars = "Automatic";
    #
    #   # Click in scroll bar to: false = jump to next page, true = jump to spot
    #   # Default: false
    #   AppleScrollerPagingBehavior = false;
    #
    #   # Spring-loading (drag a file over a folder to open it).
    #   # Default: true
    #   "com.apple.springing.enabled" = true;
    #
    #   # Spring-loading delay in seconds.
    #   # Default: 0.5
    #   "com.apple.springing.delay" = 0.5;
    #
    #   ## ── Keyboard ──────────────────────────────────────────────
    #
    #   # Key repeat rate (lower = faster).
    #   # 1 = fastest available in UI; default = 6
    #   KeyRepeat = 6;
    #
    #   # Delay before key repeat starts (lower = shorter).
    #   # 15 = shortest available in UI; default = 68
    #   InitialKeyRepeat = 68;
    #
    #   # Press-and-hold for accented characters vs. key repeat.
    #   # true = show accent popup, false = repeat key
    #   # Default: true
    #   ApplePressAndHoldEnabled = true;
    #
    #   # Full keyboard access (Tab moves focus between all controls).
    #   # 2 = all controls, 0 = text fields and lists only
    #   # Default: 0
    #   AppleKeyboardUIMode = 0;
    #
    #   ## ── Auto-correction ───────────────────────────────────────
    #
    #   # Automatic capitalisation.
    #   # Default: true
    #   NSAutomaticCapitalizationEnabled = true;
    #
    #   # Automatic spell correction.
    #   # Default: true
    #   NSAutomaticSpellingCorrectionEnabled = true;
    #
    #   # Full-stop (period) with double-space.
    #   # Default: true
    #   NSAutomaticPeriodSubstitutionEnabled = true;
    #
    #   # Smart dashes (-- → —).
    #   # Default: true
    #   NSAutomaticDashSubstitutionEnabled = true;
    #
    #   # Smart quotes (" " → " ").
    #   # Default: true
    #   NSAutomaticQuoteSubstitutionEnabled = true;
    #
    #   ## ── Windows / Title bar ───────────────────────────────────
    #
    #   # Double-click title bar action.
    #   # "Maximize" = fill screen, "Minimize" = minimise to dock, "None"
    #   # Default: "Maximize"
    #   AppleActionOnDoubleClick = "Maximize";
    #
    #   # Prefer tabs when opening documents.
    #   # "always", "fullscreen", "manual"
    #   # Default: "fullscreen"
    #   AppleWindowTabbingMode = "fullscreen";
    #
    #   ## ── Menu bar ──────────────────────────────────────────────
    #
    #   # Auto-hide the menu bar on the desktop.
    #   # Default: 0 (never auto-hide)
    #   "_HIHideMenuBar" = 0;
    #
    #   # Keep menu bar visible in full-screen apps.
    #   # Default: 0 (hides in full-screen)
    #   AppleMenuBarVisibleInFullscreen = 0;
    #
    #   ## ── Files / Save dialogs ──────────────────────────────────
    #
    #   # Expand save dialog by default.
    #   # Default: false
    #   NSNavPanelExpandedStateForSaveMode = false;
    #   NSNavPanelExpandedStateForSaveMode2 = false;
    #
    #   # Expand print dialog by default.
    #   # Default: false
    #   PMPrintingExpandedStateForPrint = false;
    #   PMPrintingExpandedStateForPrint2 = false;
    #
    #   # Save to iCloud by default (vs. local disk).
    #   # Default: true
    #   NSDocumentSaveNewDocumentsToCloud = true;
    #
    #   # Show all file extensions in Finder and dialogs.
    #   # Default: false
    #   AppleShowAllExtensions = false;
    #
    #   ## ── Locale / Units ────────────────────────────────────────
    #
    #   # 24-hour clock.
    #   # Default: false
    #   AppleICUForce24HourTime = false;
    #
    #   # Measurement units.
    #   # "Centimeters", "Inches"
    #   # Default: depends on region
    #   AppleMeasurementUnits = "Centimeters";
    #
    #   # Metric system.
    #   # Default: depends on region
    #   AppleMetricSystem = true;
    #
    #   # Temperature unit.
    #   # "Celsius", "Fahrenheit"
    #   # Default: depends on region
    #   AppleTemperatureUnit = "Celsius";
    #
    #   ## ── Misc ──────────────────────────────────────────────────
    #
    #   # Sidebar icon size.
    #   # 1 = Small, 2 = Medium, 3 = Large
    #   # Default: 2
    #   NSTableViewDefaultSizeMode = 2;
    #
    #   # Font smoothing (sub-pixel anti-aliasing).
    #   # 0 = disabled, 1-3 = increasing levels
    #   # Default: 0 on Retina, 1 on non-Retina
    #   AppleFontSmoothing = 0;
    #
    #   # Close windows when quitting an app.
    #   # true = close (don't restore), false = keep (restore on relaunch)
    #   # Default: false
    #   NSQuitAlwaysKeepsWindows = false;
    #
    #   # Force click and haptic feedback on trackpad.
    #   # Default: true
    #   "com.apple.trackpad.forceClick" = true;
    # };

    # ================================================================
    #  Dock
    # ================================================================
    # "com.apple.dock" = {
    #
    #   # Auto-hide the Dock.
    #   # Default: false
    #   autohide = false;
    #
    #   # Auto-hide delay (seconds before Dock appears on hover).
    #   # Default: 0.24
    #   autohide-delay = 0.24;
    #
    #   # Auto-hide animation duration in seconds.
    #   # Default: 0.5
    #   autohide-time-modifier = 0.5;
    #
    #   # Dock position.
    #   # "bottom", "left", "right"
    #   # Default: "bottom"
    #   orientation = "bottom";
    #
    #   # Icon size in pixels.
    #   # Default: 48
    #   tilesize = 48;
    #
    #   # Magnification on hover.
    #   # Default: false
    #   magnification = false;
    #
    #   # Magnified icon size in pixels (only if magnification = true).
    #   # Default: 64
    #   largesize = 64;
    #
    #   # Minimise animation.
    #   # "genie", "scale", "suck"
    #   # Default: "genie"
    #   mineffect = "genie";
    #
    #   # Minimise windows into their application icon.
    #   # Default: false
    #   minimize-to-application = false;
    #
    #   # Animate opening applications.
    #   # Default: true
    #   launchanim = true;
    #
    #   # Show indicator dots for open apps.
    #   # Default: true
    #   show-process-indicators = true;
    #
    #   # Show recently used apps in a separate Dock section.
    #   # Default: true
    #   show-recents = true;
    #
    #   # Only show open applications in the Dock.
    #   # Default: false
    #   static-only = false;
    #
    #   # Rearrange Spaces based on most recent use.
    #   # Default: true
    #   mru-spaces = true;
    #
    #   # Group windows by application in Mission Control.
    #   # Default: false
    #   expose-group-apps = false;
    #
    #   # ── Hot corners ──────────────────────────────────
    #   # Values:
    #   #  0 = no action        5 = start screen saver
    #   #  2 = Mission Control  6 = disable screen saver
    #   #  3 = App Exposé      10 = put display to sleep
    #   #  4 = Desktop         11 = Launchpad
    #   #                      12 = Notification Center
    #   #                      13 = Lock Screen
    #   #                      14 = Quick Note
    #   #
    #   # Modifier keys (hold while triggering):
    #   #   0 = none, 131072 = Shift, 262144 = Control,
    #   #   524288 = Option, 1048576 = Cmd
    #
    #   # Top-left corner.     Default: 0
    #   wvous-tl-corner = 0;
    #   wvous-tl-modifier = 0;
    #
    #   # Top-right corner.    Default: 0
    #   wvous-tr-corner = 0;
    #   wvous-tr-modifier = 0;
    #
    #   # Bottom-left corner.  Default: 0
    #   wvous-bl-corner = 0;
    #   wvous-bl-modifier = 0;
    #
    #   # Bottom-right corner. Default: 0
    #   wvous-br-corner = 0;
    #   wvous-br-modifier = 0;
    # };

    # ================================================================
    #  Finder
    # ================================================================
    # "com.apple.finder" = {
    #
    #   # Show hidden files (files starting with ".").
    #   # Default: false
    #   AppleShowAllFiles = false;
    #
    #   # Show path bar at bottom of Finder windows.
    #   # Default: false
    #   ShowPathbar = false;
    #
    #   # Show status bar at bottom of Finder windows.
    #   # Default: false
    #   ShowStatusBar = false;
    #
    #   # Show full POSIX path in Finder title bar.
    #   # Default: false
    #   _FXShowPosixPathInTitle = false;
    #
    #   # Sort folders before files in list view.
    #   # Default: false
    #   _FXSortFoldersFirst = false;
    #
    #   # Default view style for new windows.
    #   # "icnv" = Icon, "Nlsv" = List, "clmv" = Column, "glyv" = Gallery
    #   # Default: "icnv"
    #   FXPreferredViewStyle = "icnv";
    #
    #   # Default search scope.
    #   # "SCcf" = current folder, "SCsp" = previous scope, "SCev" = entire Mac
    #   # Default: "SCev"
    #   FXDefaultSearchScope = "SCev";
    #
    #   # Warn when changing a file extension.
    #   # Default: true
    #   FXEnableExtensionChangeWarning = true;
    #
    #   # Automatically remove Trash items after 30 days.
    #   # Default: false
    #   FXRemoveOldTrashItems = false;
    #
    #   # New Finder window target.
    #   # "PfCm" = Computer, "PfVo" = Volume, "PfHm" = Home,
    #   # "PfDe" = Desktop,  "PfDo" = Documents, "PfAF" = All My Files,
    #   # "PfLo" = Other (specify NewWindowTargetPath)
    #   # Default: "PfHm"
    #   NewWindowTarget = "PfHm";
    #
    #   # Allow quitting Finder with Cmd-Q.
    #   # Default: false
    #   QuitMenuItem = false;
    #
    #   # Show icons on Desktop.
    #   # Default: true
    #   ShowExternalHardDrivesOnDesktop = true;
    #
    #   # Default: false
    #   ShowHardDrivesOnDesktop = false;
    #
    #   # Default: true
    #   ShowMountedServersOnDesktop = true;
    #
    #   # Default: true
    #   ShowRemovableMediaOnDesktop = true;
    #
    #   # Show iCloud Drive in sidebar.
    #   # Default: true
    #   FXICloudDriveEnabled = true;
    #
    #   # Sync Desktop to iCloud Drive.
    #   # Default: false
    #   FXICloudDriveDesktop = false;
    #
    #   # Sync Documents to iCloud Drive.
    #   # Default: false
    #   FXICloudDriveDocuments = false;
    # };

    # ================================================================
    #  Trackpad
    # ================================================================
    # "com.apple.AppleMultitouchTrackpad" = {
    #
    #   # Tap to click.
    #   # Default: 0 (disabled)
    #   Clicking = 0;
    #
    #   # Three-finger drag.
    #   # Default: 0 (disabled)
    #   TrackpadThreeFingerDrag = 0;
    #
    #   # Two-finger right-click.
    #   # Default: 1 (enabled)
    #   TrackpadRightClick = 1;
    #
    #   # Click pressure threshold.
    #   # 0 = Light, 1 = Medium (default), 2 = Firm
    #   FirstClickThreshold = 1;
    #   SecondClickThreshold = 1;
    #
    #   # Drag lock (lift finger and continue dragging).
    #   # Default: 0 (disabled)
    #   DragLock = 0;
    #
    #   # Dragging with trackpad (without three-finger drag).
    #   # Default: 0 (disabled)
    #   Dragging = 0;
    #
    #   # Pinch to zoom.
    #   # Default: 1 (enabled)
    #   TrackpadPinch = 1;
    #
    #   # Rotation gesture.
    #   # Default: 1 (enabled)
    #   TrackpadRotate = 1;
    #
    #   # Two-finger swipe from right edge for Notification Center.
    #   # 0 = disabled, 3 = enabled
    #   # Default: 3
    #   TrackpadTwoFingerFromRightEdgeSwipeGesture = 3;
    #
    #   # Four-finger horizontal swipe (switch Spaces).
    #   # 0 = disabled, 2 = enabled
    #   # Default: 2
    #   TrackpadFourFingerHorizSwipeGesture = 2;
    #
    #   # Four-finger vertical swipe (Mission Control / App Exposé).
    #   # 0 = disabled, 2 = enabled
    #   # Default: 2
    #   TrackpadFourFingerVertSwipeGesture = 2;
    #
    #   # Four-/five-finger pinch (Launchpad / show desktop).
    #   # 0 = disabled, 2 = enabled
    #   # Default: 2
    #   TrackpadFourFingerPinchGesture = 2;
    #   TrackpadFiveFingerPinchGesture = 2;
    #
    #   # Three-finger horizontal swipe (switch Spaces if three-finger drag off).
    #   # 0 = disabled, 2 = enabled
    #   # Default: 2
    #   TrackpadThreeFingerHorizSwipeGesture = 2;
    #
    #   # Three-finger vertical swipe (Mission Control if three-finger drag off).
    #   # 0 = disabled, 2 = enabled
    #   # Default: 2
    #   TrackpadThreeFingerVertSwipeGesture = 2;
    #
    #   # Three-finger tap (Look up / data detectors).
    #   # 0 = disabled, 2 = enabled
    #   # Default: 0
    #   TrackpadThreeFingerTapGesture = 0;
    # };

    # ================================================================
    #  Mouse (Bluetooth)
    # ================================================================
    # "com.apple.driver.AppleBluetoothMultitouch.mouse" = {
    #
    #   # Mouse button mode.
    #   # "OneButton", "TwoButton"
    #   # Default: "OneButton"
    #   MouseButtonMode = "OneButton";
    # };

    # ================================================================
    #  Screen capture
    # ================================================================
    # "com.apple.screencapture" = {
    #
    #   # Save location.
    #   # Default: "~/Desktop"
    #   location = "~/Desktop";
    #
    #   # Image format.
    #   # "png", "jpg", "gif", "pdf", "tiff"
    #   # Default: "png"
    #   type = "png";
    #
    #   # Include shadow in window screenshots.
    #   # false = include shadow, true = no shadow
    #   # Default: false
    #   disable-shadow = false;
    #
    #   # Show floating thumbnail after capture.
    #   # Default: true
    #   show-thumbnail = true;
    # };

    # ================================================================
    #  Menu bar clock
    # ================================================================
    # "com.apple.menuextra.clock" = {
    #
    #   # Show date.
    #   # 0 = when space allows, 1 = always, 2 = never
    #   # Default: 1
    #   ShowDate = 1;
    #
    #   # Show day of week.
    #   # Default: true
    #   ShowDayOfWeek = true;
    #
    #   # Show AM/PM indicator (12-hour clock).
    #   # Default: true
    #   ShowAMPM = true;
    #
    #   # Show seconds.
    #   # Default: false
    #   ShowSeconds = false;
    #
    #   # Use analog clock.
    #   # Default: false
    #   IsAnalog = false;
    # };

    # ================================================================
    #  Window Manager (tiling / Stage Manager)
    # ================================================================
    # "com.apple.WindowManager" = {
    #
    #   # Margins (gaps) around tiled windows.
    #   # 1 = margins, 0 = no margins (flush to edges)
    #   # Default: 1
    #   EnableTiledWindowMargins = 1;
    #
    #   # Click wallpaper to reveal desktop.
    #   # 0 = always, 1 = only in Stage Manager
    #   # Default: 0  [macOS Sonoma+]
    #   HideDesktop = 0;
    #
    #   # Enable Stage Manager.
    #   # Default: false
    #   GloballyEnabled = false;
    #
    #   # Auto-hide Stage Manager strip.
    #   # Default: false
    #   AutoHide = false;
    #
    #   # Hide widgets on desktop.
    #   # Default: 0 (show)
    #   StandardHideWidgets = 0;
    #
    #   # Hide widgets in Stage Manager.
    #   # Default: 0 (show)
    #   StageManagerHideWidgets = 0;
    #
    #   # Hide desktop icons.
    #   # Default: false
    #   StandardHideDesktopIcons = false;
    # };

    # ================================================================
    #  Spaces (Mission Control)
    # ================================================================
    # "com.apple.spaces" = {
    #
    #   # Displays have separate Spaces.
    #   # true = separate Spaces per display, false = spans all displays
    #   # Default: true
    #   "spans-displays" = false;
    # };

    # ================================================================
    #  Login window
    # ================================================================
    # "com.apple.loginwindow" = {
    #
    #   # Guest account.
    #   # Default: true
    #   GuestEnabled = true;
    #
    #   # Show input menu in login window.
    #   # Default: false
    #   showInputMenu = false;
    #
    #   # Disable reopen windows on login.
    #   # Default: false
    #   TALLogoutSavesState = false;
    # };

    # ================================================================
    #  Software Update
    # ================================================================
    # "com.apple.SoftwareUpdate" = {
    #
    #   # Check for updates automatically.
    #   # Default: true
    #   AutomaticCheckEnabled = true;
    #
    #   # Download updates automatically.
    #   # Default: true
    #   AutomaticDownload = true;
    #
    #   # Install macOS updates automatically.
    #   # Default: true
    #   AutomaticallyInstallMacOSUpdates = true;
    #
    #   # Install critical security updates automatically.
    #   # Default: true
    #   CriticalUpdateInstall = true;
    # };

    # ================================================================
    #  Desktop Services
    # ================================================================
    # "com.apple.desktopservices" = {
    #
    #   # Prevent .DS_Store on network volumes.
    #   # Default: false
    #   DSDontWriteNetworkStores = false;
    #
    #   # Prevent .DS_Store on USB volumes.
    #   # Default: false
    #   DSDontWriteUSBStores = false;
    # };

    # ================================================================
    #  Launch Services
    # ================================================================
    # "com.apple.LaunchServices" = {
    #
    #   # Quarantine dialog ("Are you sure you want to open this?").
    #   # Default: true
    #   LSQuarantine = true;
    # };

    # ================================================================
    #  Advertising / Privacy
    # ================================================================
    # "com.apple.AdLib" = {
    #
    #   # Apple personalised advertising.
    #   # Default: true
    #   allowApplePersonalizedAdvertising = true;
    # };

    # ================================================================
    #  Activity Monitor
    # ================================================================
    # "com.apple.ActivityMonitor" = {
    #
    #   # Default filter.
    #   # 100 = All Processes, 101 = All Processes Hierarchically,
    #   # 102 = My Processes, 103 = System Processes,
    #   # 104 = Other User Processes, 105 = Active Processes,
    #   # 106 = Inactive Processes, 107 = Windowed Processes
    #   # Default: 100
    #   ShowCategory = 100;
    #
    #   # Dock icon type.
    #   # 0 = Application icon, 2 = Network, 3 = Disk, 5 = CPU, 6 = CPU History
    #   # Default: 0
    #   IconType = 0;
    #
    #   # Open main window on launch.
    #   # Default: true
    #   OpenMainWindow = true;
    # };

    # ================================================================
    #  TextEdit
    # ================================================================
    # "com.apple.TextEdit" = {
    #
    #   # Default to plain text (vs. rich text).
    #   # true = rich text, false = plain text
    #   # Default: true
    #   RichText = true;
    #
    #   # Open and save encoding.
    #   # 4 = UTF-8
    #   # Default: 4
    #   PlainTextEncoding = 4;
    #   PlainTextEncodingForWrite = 4;
    # };

    # ================================================================
    #  Safari
    # ================================================================
    # "com.apple.Safari" = {
    #
    #   # Show full URL in address bar.
    #   # Default: false
    #   ShowFullURLInSmartSearchField = false;
    #
    #   # Enable developer menu.
    #   # Default: false
    #   IncludeDevelopMenu = false;
    #   WebKitDeveloperExtrasEnabledPreferenceKey = false;
    #   "com.apple.Safari.ContentPageGroupIdentifier.WebKit2DeveloperExtrasEnabled" = false;
    #
    #   # Open "safe" files after downloading.
    #   # Default: true
    #   AutoOpenSafeDownloads = true;
    #
    #   # Show favourites bar.
    #   # Default: false
    #   ShowFavoritesBar-v2 = false;
    #
    #   # Enable extensions.
    #   # Default: false
    #   ExtensionsEnabled = false;
    # };

    # ================================================================
    #  Screensaver
    # ================================================================
    # "com.apple.screensaver" = {
    #
    #   # Ask for password after screensaver activates.
    #   # 1 = require password
    #   # Default: 1
    #   askForPassword = 1;
    #
    #   # Delay (seconds) before password is required.
    #   # Default: 5
    #   askForPasswordDelay = 5;
    # };

    # ================================================================
    #  Bluetooth
    # ================================================================
    # "com.apple.BluetoothAudioAgent" = {
    #
    #   # Increase Bluetooth audio bitrate for better quality.
    #   # Default: (varies)
    #   "Apple Bitpool Min (editable)" = 40;
    # };

    # ================================================================
    #  Disk Utility
    # ================================================================
    # "com.apple.DiskUtility" = {
    #
    #   # Show all devices (including partitions).
    #   # Default: false
    #   SidebarShowAllDevices = false;
    #
    #   # Enable debug menu.
    #   # Default: false
    #   DUDebugMenuEnabled = false;
    #
    #   # Show advanced image options.
    #   # Default: false
    #   "advanced-image-options" = false;
    # };

    # ================================================================
    #  Help Viewer
    # ================================================================
    # "com.apple.helpviewer" = {
    #
    #   # Help Viewer windows float on top.
    #   # Default: false
    #   DevMode = false;
    # };

    # ================================================================
    #  Printing
    # ================================================================
    # "com.apple.print.PrintingPrefs" = {
    #
    #   # Quit printer app when print jobs complete.
    #   # Default: true
    #   "Quit When Finished" = true;
    # };

    # ================================================================
    #  Photos
    # ================================================================
    # "com.apple.ImageCapture" = {
    #
    #   # Prevent Photos from opening when a device is plugged in.
    #   # Default: (absent — Photos opens)
    #   disableHotPlug = true;
    # };

    # ================================================================
    #  Time Machine
    # ================================================================
    # "com.apple.TimeMachine" = {
    #
    #   # Prevent Time Machine from prompting for new disks.
    #   # Default: false
    #   DoNotOfferNewDisksForBackup = false;
    # };
  };
}
