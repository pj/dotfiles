{ pkgs, inputs, ... }:
{
  programs.home-manager.enable = true;

  programs.alacritty = {
    enable = true;
    settings = {
      shell.program = "zsh";

      font.normal = {
        family = "Monaco Nerd Font Mono";
        style = "Book";
      };
    };
  };

  programs.git = {
    enable = true;
    userEmail = "paul@johnson.kiwi.nz";
    userName = "Paul Johnson";
    aliases = {
      gcb = "checkout -b";
    };
    extraConfig.init.defaultBranch = "main";
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

  programs.tmux = {
    enable = true;
    shell = "${pkgs.zsh}/bin/zsh";
  };

  programs.plasma = {
    enable = true;

    workspace = {
      lookAndFeel = "org.kde.breezedark.desktop";
      cursor = {
        theme = "Bibata-Modern-Ice";
        size = 32;
      };
      wallpaper = "${pkgs.kdePackages.plasma-workspace-wallpapers}/share/wallpapers/Patak/contents/images/1080x1920.png";
    };

    fonts = {
      general = {
        family = "Noto Sans";
        pointSize = 12;
      };
    };

    desktop.widgets = [
    ];

    panels = [
      # Windows-like panel at the bottom
      {
        location = "bottom";
        hiding = "autohide";
        height = 70;
        floating = true;

        widgets = [
          "org.kde.plasma.panelspacer"
          {
            name = "org.kde.plasma.icontasks";
            config = {
              General = {
                launchers = [
                  # "applications:org.kde.dolphin.desktop"
                  # "applications:org.kde.konsole.desktop"
                ];
              };
            };
          }
          "org.kde.plasma.panelspacer"
        ];
      }
      # Application name, Global menu and Song information and playback controls at the top
      {
        location = "top";
        height = 32;
        hiding = "autohide";
        floating = true;
        widgets = [
          {
            name = "org.kde.plasma.kickoff";
            config = {
              General = {
                icon = "nix-snowflake-white";
                alphaSort = true;
              };
            };
          }
          {
            applicationTitleBar = {
              behavior = {
                activeTaskSource = "activeTask";
              };
              layout = {
                elements = [ "windowTitle" ];
                horizontalAlignment = "left";
                showDisabledElements = "deactivated";
                verticalAlignment = "center";
              };
              overrideForMaximized.enable = false;
              titleReplacements = [
                {
                  type = "regexp";
                  originalTitle = "^Brave Web Browser$";
                  newTitle = "Brave";
                }
                {
                  type = "regexp";
                  originalTitle = ''\\bDolphin\\b'';
                  newTitle = "File manager";
                }
              ];
              windowTitle = {
                font = {
                  bold = true;
                  fit = "fixedSize";
                  size = 12;
                };
                hideEmptyTitle = true;
                margins = {
                  bottom = 0;
                  left = 10;
                  right = 5;
                  top = 0;
                };
                source = "appName";
              };
            };
          }
          "org.kde.plasma.appmenu"
          "org.kde.plasma.panelspacer"
          {
            systemTray.items = {
              shown = [
                "org.kde.plasma.bluetooth"
                "org.kde.plasma.networkmanagement"
                "org.kde.plasma.volume"
              ];
              # # And explicitly hide networkmanagement and volume
              # hidden = [
              # ];
            };
          }
          {
            digitalClock = {
              calendar.firstDayOfWeek = "sunday";
              time.format = "12h";
            };
          }
        ];
      }
    ];

    window-rules = [
      {
        description = "Dolphin";
        match = {
          window-class = {
            value = "dolphin";
            type = "substring";
          };
          window-types = [ "normal" ];
        };
        apply = {
          noborder = {
            value = true;
            apply = "force";
          };
          # `apply` defaults to "apply-initially"
          maximizehoriz = true;
          maximizevert = true;
        };
      }
    ];

    powerdevil = {
      AC = {
        powerButtonAction = "lockScreen";
        autoSuspend = {
          action = "shutDown";
          idleTimeout = 1000;
        };
        turnOffDisplay = {
          idleTimeout = 1000;
          idleTimeoutWhenLocked = "immediately";
        };
      };
      battery = {
        powerButtonAction = "sleep";
        whenSleepingEnter = "standbyThenHibernate";
      };
      lowBattery = {
        whenLaptopLidClosed = "hibernate";
      };
    };

    kwin = {
      edgeBarrier = 0; # Disables the edge-barriers introduced in plasma 6.1
      cornerBarrier = false;

      # scripts.polonium.enable = true;
    };

    kscreenlocker = {
      lockOnResume = true;
      timeout = 10;
    };

    # hotkeys.commands."launch-konsole" = {
    #   name = "Launch Konsole";
    #   key = "Meta+Alt+K";
    #   command = "konsole";
    # };

    #
    # Some mid-level settings:
    #
    shortcuts = {
      ksmserver = {
        "Lock Session" = [
          "Screensaver"
          "Meta+Ctrl+Alt+L"
        ];
      };

      kwin = {
        # "Expose" = "Meta+,";
        # "Switch Window Down" = "Meta+J";
        # "Switch Window Left" = "Meta+H";
        # "Switch Window Right" = "Meta+L";
        # "Switch Window Up" = "Meta+K";
        "Walk Throw Windows" = "Meta+Tab";
        "Walk Throw Windows (Reverse)" = "Meta+Shift+Tab";
      };

      "org.kde.krunner.desktop" = {
        _launch = "Meta+Space";
      };
    };

    #
    # Some low-level settings:
    #
    configFile = {
      baloofilerc."Basic Settings"."Indexing-Enabled" = false;
      kwinrc."org.kde.kdecoration2".ButtonsOnLeft = "SF";
      # Disable default top left hot corner that shows desktops
      kwinrc."Effect-overview".BorderActivate = {
        value = 9;
      };
      kscreenlockerrc = {
        Greeter.WallpaperPlugin = "org.kde.potd";
        # To use nested groups use / as a separator. In the below example,
        # Provider will be added to [Greeter][Wallpaper][org.kde.potd][General].
        "Greeter/Wallpaper/org.kde.potd/General".Provider = "bing";
      };
      kdeglobals.Shortcuts = {
        Copy = "Ctrl+C; Meta+C;";
        Cut = "Meta+X; Ctrl+X;";
        Find = "Meta+F; Ctrl+F";
        New = "Meta+N; Ctrl+N";
        Paste = "Meta+V; Ctrl+V";
        Quit = "Ctrl+Q; Meta+Q";
        Redo = "Meta+Shift+Z; Ctrl+Shift+Z";
        Save = "Meta+S; Ctrl+S";
        SelectAll = "Ctrl+A; Meta+A";
        Undo = "Meta+Z; Ctrl+Z";
      };

    };

    krunner.position = "center";
  };

  services.xremap.config.modmap = [
    {
      name = "Example ctrl-u > pageup rebind";
      remap = { "C-u" = "PAGEUP"; };
    }
  ];

  home.stateVersion = "24.05";
  home.file.".local/share/fonts/Monaco Nerd Font Complete Mono.ttf".source = ./../../${"Monaco Nerd Font Complete Mono.ttf"};
  home.file.".tmux.conf".source = ./../../tmux.conf;
  home.file.".config/commandline_thing/config.yaml".source = ./../../commandline_thing.yaml;
  home.packages = [
    inputs.commandline_thing.packages.${pkgs.system}.default
    pkgs.ripgrep
  ];

}
