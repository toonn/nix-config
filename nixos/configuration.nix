{ config, pkgs, ... }:
let nix-config-repo = /home/toonn/src/nix-config;
in {
  disabledModules = [ "services/backup/borgbackup.nix" "services/networking/bitlbee.nix" ];
  imports =
    [ /etc/nixos/hardware-configuration.nix
      <home-manager/nixos>
      (nix-config-repo + "/modules/borgbackup/borgbackup.nix")
      (nix-config-repo + "/modules/bitlbee.nix")
      (nix-config-repo + "/modules/mdns-publisher.nix")
    ];

  nix = {
    settings = {
      # Haskell.nix cache
      trusted-public-keys = [
        "hydra.iohk.io:f/Ea+s+dFdN+3Y/G+FDgSq+a5NEWhJGzdjvKNGv0/EQ="
      ];
      substituters = [ "https://cache.iog.io" ];
    };
  };

  nixpkgs = {
    config.allowUnfreePredicate = p: builtins.elem (pkgs.lib.getName p) [
      "broadcom-sta"
    ];

    overlays = [
      (import /home/toonn/src/nix-config/overlays/mdns-publisher.nix)
    ];
  };

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  fileSystems."/".options = [ "compress=zstd" ];

  hardware.cpu.intel.updateMicrocode = true;

  networking.hostName = "yorp";
  # Connman instead
  # networking.wireless = { enable = true;  # Enables wpa_supplicant.
  #                         interfaces = [ "wls4" ];
  #                       };

  time.timeZone = "Europe/Amsterdam";

  # The global useDHCP flag is deprecated, therefore explicitly set to false
  # here.  Per-interface useDHCP will be mandatory in the future, so this
  # generated config replicates the default behaviour.
  networking.useDHCP = false;
  networking.interfaces.ens5.useDHCP = true;

  # Select internationalisation properties.
  i18n.defaultLocale = "en_DK.UTF-8";
  console = { font = "Lat2-Terminus16";
              keyMap = "dvorak";
            };

  services.xserver = {
    enable = true;
    layout = "dvorak";
    xkbOptions = "caps:escape";
    displayManager = { defaultSession = "none+openbox";
                       lightdm = { enable = true;
                                   greeters.mini = { enable = true;
                                                     user = "toonn";
                                                   };
                                 };
                     };
    windowManager.openbox.enable = true;
    # Enable touchpad support (enabled default in most desktopManager).
    libinput.enable = true;
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;

  users.users.toonn = {
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
    isNormalUser = true;
    shell = with pkgs; fish;
  };

  home-manager.users.toonn = import /home/toonn/.config/nixpkgs/home.nix;

  environment.shells = with pkgs; [ fish ];
  environment.systemPackages = with pkgs; [
    vim
  ];

  # Enable screen bright fn keys together with services.actkbd
  programs.light.enable = true;

  # Bind fn brightness keys to light utility commands
  services.actkbd = {
    enable = true;
    bindings = [ { keys = [ 59 464 ]; # fn pressed
                   events = [ "key" ];
                   command = "/run/current-system/sw/bin/light -U 10";
                 }
                 { keys = [ 60 464 ]; # fn pressed
                   events = [ "key" ];
                   command = "/run/current-system/sw/bin/light -A 10";
                 }
               ];
  };
  services.avahi = { allowPointToPoint = true;
                     enable = true;
                     ipv6 = false;
                     # This adds mdns_minimal, which only works for 169.254.x.x
                     # and not subdomains, dropping in favor of adding mdns4 to
                     # nsswitch hosts manually.
                     # nssmdns = true;
                     publish = { enable = true;
                                 addresses = true;
                               };
                     # Necessary because mDNS requests do not cross subnet
                     # boundaries.
                     # reflector = true;
                   };

  services.bitlbee = { enable = true;
                       plugins = with pkgs; [ bitlbee-facebook ];
                       libpurple_plugins = with pkgs; [ purple-matrix ];
                     };

  services.borgbackup.jobs =
    let job = options: { compression = "auto,zstd";
                         encryption.mode = "none";
                         group = "users";
                         persistent = true;
                         prune.keep = { within = "1d";
                                        daily = 1;
                                        weekly = 2;
                                        monthly = 2;
                                      };
                         randomizedDelaySec = "10 min";
                         repo = "toxsol:/vault/borgbackups";
                         restartSec = "10 min";
                         startAt = "daily";
                         user = "toonn";
                       } // options;
    in {
    fitnessroutine = job { paths = "/home/toonn/fitnessroutine"; };
    irclogs = job { paths = "/home/toonn/.irclogs";
                    startAt = "hourly";
                  };
    irssiconfig = job { paths = "/home/toonn/.irssi"; };
    taskell = job { paths = "/home/toonn/taskell.md"; };
  };

  services.connman = { enable = true;
                       enableVPN = false;
                       # wpa_supplicant issue should be fixed in 21.11
                       wifi.backend = "iwd";
                     };

  services.openssh.enable = true;

  services.tailscale.enable = true;

  services.toxvpn = { enable = true;
                      localip = "10.0.0.10";
                    };

  system.nssModules = with pkgs; [ nssmdns ];
  system.nssDatabases.hosts = [ "mdns4 [NOTFOUND=return]" ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.05"; # Did you read the comment?

}
