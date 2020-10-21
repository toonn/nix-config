{ config, pkgs, ... }:

{
  imports = [ <home-manager/nix-darwin> ];

  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = with pkgs; [ ];

  # Use a custom configuration.nix location.
  # $ darwin-rebuild switch -I darwin-config=$HOME/.config/nixpkgs/darwin/configuration.nix
  environment.darwinConfig = "$HOME/.config/nixpkgs/darwin/configuration.nix";

  # Auto upgrade nix package and the daemon service.
  # services.nix-daemon.enable = true;
  nix.package = pkgs.nix;

  # Create /etc/bashrc that loads the nix-darwin environment.
  # programs.bash.enable = true;
  # programs.zsh.enable = true;
  programs.fish.enable = true;

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;

  # You should generally set this to the total number of logical cores in your system.
  # $ sysctl -n hw.ncpu
  nix.maxJobs = 8;
  nix.buildCores = 0;
  nix.binaryCaches = [ "https://iohk.cachix.org" "https://hydra.iohk.io" ];
  nix.binaryCachePublicKeys =
    [ "iohk.cachix.org-1:DpRUyj7h7V830dp/i6Nti+NEO2/nhblbov/8MW7Rqoo="
      "hydra.iohk.io:f/Ea+s+dFdN+3Y/G+FDgSq+a5NEWhJGzdjvKNGv0/EQ="
    ];


  # Personal setup
  environment.shells = [ pkgs.fish ];
  environment.variables = { VISUAL = "vim"; };

  networking.hostName = "terra";

  # nixpkgs.config = { allowUnfree = true; };
  # nixpkgs.overlays = [ ];

  #programs.tmux.enable = true;
  #programs.tmux.enableSensible = true;

  #programs.vim.enable = true;
  
  system.defaults = { NSGlobalDomain =
                        { AppleMeasurementUnits = "Centimeters";
                          AppleMetricUnits = 1;
                          AppleShowAllExtensions = true;
                          AppleTemperatureUnit = "Celsius";
                          NSAutomaticCapitalizationEnabled = false;
                          NSAutomaticDashSubstitutionEnabled = false;
                          NSAutomaticPeriodSubstitutionEnabled = false;
                          NSAutomaticQuoteSubstitutionEnabled = false;
                          NSAutomaticSpellingCorrectionEnabled = false;
                          NSDisableAutomaticTermination = true;
                          NSDocumentSaveNewDocumentsToCloud = false;
                          NSNavPanelExpandedStateForSaveMode = true;
                          NSNavPanelExpandedStateForSaveMode2 = true;
                          NSTableViewDefaultSizeMode = 1;
                          NSWindowResizeTime = "0.0001";
                          PMPrintingExpandedStateForPrint = true;
                          PMPrintingExpandedStateForPrint2 = true;
                          "com.apple.mouse.tapBehavior" = 1;
                          "com.apple.swipescrolldirection" = true;
                          "com.apple.trackpad.enableSecondaryClick" = true;
                        };
                      LaunchServices.LSQuarantine = false;
                      dock = { autohide = true;
                               autohide-delay = "0.15";
                               autohide-time-modifier = "0.5";
                               mineffect = "scale";
                               orientation = "left";
                               show-recents = false;
                               tilesize = 28;
                             };
                      finder.FXEnableExtensionChangeWarning = false;
                      trackpad = { Clicking = true;
                                   TrackpadRightClick = true;
                                   TrackpadThreeFingerDrag = true;
                                 };
                    };

  system.activationScripts.userDefaults.text = ''
    defaults write .GlobalPreferences 'com.apple.sound.beep.sound' \
      -string '/System/Library/Sounds/Morse.aiff'
    '';

  system.keyboard = { enableKeyMapping = true;
                      remapCapsLockToEscape = true;
                    };

  fonts = { enableFontDir = true;
            fonts = with pkgs; [ dejavu_fonts
                                 #emojione
                                 symbola
                               ];
          };

  users.users.toonn = { home = "/Users/toonn";
                        shell = pkgs.fish; };

  # Otherwise hm Applications don't end up in .nix-profile
  home-manager.useUserPackages = false;
  home-manager.users.toonn = import ~/.config/nixpkgs/home.nix;
}
