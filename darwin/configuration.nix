{ config, pkgs, lib, ... }:

{
  imports = [ <home-manager/nix-darwin> ];

  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = with pkgs; [ ];

  # Use a custom configuration.nix location.
  # $ darwin-rebuild switch -I darwin-config=$HOME/.config/nixpkgs/darwin/configuration.nix
  environment.darwinConfig = "$HOME/.config/nixpkgs/darwin/configuration.nix";

  # Auto upgrade nix package and the daemon service.
  services.nix-daemon.enable = true;
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
  nix.settings.max-jobs = 2;
  nix.settings.cores = 1;
  nix.settings.substituters = [ "https://iohk.cachix.org"
                                "https://hydra.iohk.io"
                              ];
  nix.settings.trusted-public-keys =
    [ "iohk.cachix.org-1:DpRUyj7h7V830dp/i6Nti+NEO2/nhblbov/8MW7Rqoo="
      "hydra.iohk.io:f/Ea+s+dFdN+3Y/G+FDgSq+a5NEWhJGzdjvKNGv0/EQ="
    ];


  # Personal setup
  environment.shells = [ pkgs.fish ];
  environment.variables = { VISUAL = "vim"; };

  launchd.user.agents = {
    arbtt = {
      script = ''
        DATADIR="''${XDG_DATA_HOME:-$HOME/.local/share/arbtt}"
        LOG="''${DATADIR}/''$(date +%Y).capture"
        STDERR="''${DATADIR}/''$(date +%Y-%m).out"
        STDOUT="''${DATADIR}/''$(date +%Y-%m).err"
        mkdir -p "''${DATADIR}"
        arbtt-capture --logfile="''${LOG}" 2>''${STDERR} >''${STDOUT}
      '';
      path = with pkgs; [ arbtt coreutils ];
      serviceConfig.KeepAlive = true;
      serviceConfig.StandardErrorPath = "/Users/toonn/arbtt.stderr";
    };
  };

  networking.hostName = "terra";

  nixpkgs.config = {
    allowUnfreePredicate = p: builtins.elem (lib.getName p) [
        "joypixels"
      ];
    joypixels.acceptLicense = true;
    packageOverrides = pkgs: {
      nur = import (builtins.fetchTarball
        "https://github.com/nix-community/NUR/archive/master.tar.gz") {
          inherit pkgs;
        };
    };
  };
  nixpkgs.overlays = [ # (import ~/.config/nixpkgs/overlays/joypixels.nix)
                       (import ~/.config/nixpkgs/overlays/haskell-packages.nix)
                       # (import ~/.config/nixpkgs/overlays/nix.nix)
                     ];

  #programs.tmux.enable = true;
  #programs.tmux.enableSensible = true;

  #programs.vim.enable = true;

  # Doesn't work with old macOS
  #services.karabiner-elements.enable = true;
  
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
                          NSWindowResizeTime = 0.0001;
                          PMPrintingExpandedStateForPrint = true;
                          PMPrintingExpandedStateForPrint2 = true;
                          "com.apple.mouse.tapBehavior" = 1;
                          "com.apple.swipescrolldirection" = true;
                          "com.apple.trackpad.enableSecondaryClick" = true;
                        };
                      LaunchServices.LSQuarantine = false;
                      dock = { autohide = true;
                               autohide-delay = 0.15;
                               autohide-time-modifier = 0.5;
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
                      CustomUserPreferences = {
                        "org.gpgtools.common" = { UseKeychain = false; };
                      };
                    };

  system.activationScripts.userDefaults.text = ''
    defaults write .GlobalPreferences 'com.apple.sound.beep.sound' \
      -string '/System/Library/Sounds/Morse.aiff'
    '';

  system.keyboard = { enableKeyMapping = true;
                      remapCapsLockToEscape = true;
                    };

  fonts = { fontDir.enable = true;
            fonts = with pkgs; [ dejavu_fonts
                                 #emojione  # Doesn't build
                                 #symbola  # Not foss anymore
                                 #noto-fonts-emoji  # How to prioritize B&W?
                                 #openmoji  # Not packaged? :"(
                                 joypixels
                               ];
          };

  users.users.toonn = { home = "/Users/toonn";
                        shell = pkgs.fish; };

  # Otherwise hm Applications don't end up in .nix-profile
  home-manager.useUserPackages = false;
  # home-manager.useGlobalPackages = true; # Doesn't exist yet?
  home-manager.users.toonn = import ~/.config/nixpkgs/home.nix;
}
