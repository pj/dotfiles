# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, inputs, ... }:

{
  imports =
    [
      # Include the results of the hardware scan.
      ./hardware-configuration.nix
      inputs.home-manager.nixosModules.default
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixbox"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "America/Los_Angeles";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.paul = {
    isNormalUser = true;
    description = "paul";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
      zsh-autosuggestions
      zsh-fzf-history-search
    ];
    shell = pkgs.zsh;
  };

  home-manager.users.paul = {
    programs.home-manager.enable = true;
    programs.git = {
      enable = true;
      userEmail = "paul@johnson.kiwi.nz";
      userName = "Paul Johnson";
      aliases = {
        gcb = "checkout -b";
      };

    };
    programs.zsh = {
      enable = true;
      enableCompletion = true;
      autosuggestion = {
        enable = true;
      };
      history = {
        save = 100000;
        size = 100000;
      };
      initExtraFirst = ''
        export ZSH_CUSTOM="$HOME/dotfiles/zsh_themes"
      '';
      initExtra = ''
        bindkey -M viins 'kj' vi-cmd-mode
        export EDITOR=vim
      '';
      dotDir = ".config/zsh";
      oh-my-zsh = {
        enable = true;
        theme = "wezm++";
        plugins = [
          "vi-mode"
          "git"
          "autojump"
        ];
      };
      plugins = [
        {
          name = "zsh-autosuggestions";
          file = "zsh-autosuggestions.zsh";
          src = pkgs.fetchFromGitHub {
            owner = "zsh-users";
            repo = "zsh-autosuggestions";
            rev = "v0.7.0";
            sha256 = "sha256-KLUYpUu4DHRumQZ3w59m9aTW6TBKMCXl2UcKi4uMd7w=";
          };
        }

        {
          name = "zsh-fzf-history-search";
          file = "zsh-fzf-history-search.zsh";
          src = pkgs.fetchFromGitHub {
            owner = "joshskidmore";
            repo = "zsh-fzf-history-search";
            rev = "master";
            sha256 = "sha256-tQqIlkgIWPEdomofPlmWNEz/oNFA1qasILk4R5RWobY=";
          };
        }
      ];
    };
    programs.autojump.enable = true;
    programs.fzf = {
      enable = true;
      enableZshIntegration = true;
    };
    home.stateVersion = "24.05";
    # home.file.".oh-my-zsh/themes".source = ../../zsh_themes;
    # home.file.".oh-my-zsh/themes".recursive = true;
    home.file.".local/share/fonts/MonacoNerdFontMono-Regular.ttf".source = ./../../MonacoNerdFontMono-Regular.ttf;
  };

  # Install firefox.
  programs.firefox.enable = false;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  programs.zsh.enable = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim
    wget
    alacritty
    vscode
    brave
    git
    (chromium.override { enableWideVine = true; })
    ffmpeg
    btop
    gnomeExtensions.vitals
    python312
    _1password-gui
    _1password
    tmux
    # Needed for nix vscode extension to format properly
    nixpkgs-fmt
    zsh

  ];

  ## necessary for arduino development with platformio core
  services.udev.packages = [
    pkgs.platformio-core
    pkgs.openocd
  ];

  # Gigabyte Aorus PRO AX B550i bug - this causes the computer to immediately awake from sleep after suspend
  services.udev.extraRules = lib.strings.concatStringsSep ", " [
    ''ACTION=="add"''

    # See below on how to get the correct values for these three
    ''SUBSYSTEM=="pci"''
    ''ATTR{vendor}=="0x1022"''
    ''ATTR{device}=="0x1483"''

    ''ATTR{power/wakeup}="disabled"''
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?

  # enable nix command and nix flakes
  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
    };
  };

  fonts.packages = with pkgs; [
  (nerdfonts.override { fonts = [ "Monaco" ]; })
];  
}
