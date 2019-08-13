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


  # Personal setup
  environment.loginShell = "fish";
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

  system.keyboard = { enableKeyMapping = true;
                      remapCapsLockToEscape = true;
                    };

  fonts = { enableFontDir = true;
            fonts = with pkgs; [ dejavu_fonts
                                 #emojione
                                 symbola
                               ];
          };

  home-manager.useUserPackages = true;
  home-manager.users.toonn = import ~/.config/nixpkgs/home.nix;
}
