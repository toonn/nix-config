{ config, pkgs, ... }:
{
  disabledModules = [ "services/backup/borgbackup.nix" "services/networking/bitlbee.nix" ];
  imports =
    [ ./hardware-configuration.nix
      <home-manager/nixos>
      /home/toonn/src/nix-config/borgbackup.nix
      (builtins.fetchurl { url = "https://raw.githubusercontent.com/NixOS/nixpkgs/f4c69e198ce8a8208995e43133d4c32d2045a587/nixos/modules/services/networking/bitlbee.nix"; sha256 = "1d120xrhq6hzn2rnhqh69dzs4gy6wb5pywni13ir4ldkrxfx40yw"; })
      /home/toonn/src/nix-config/mdns-publisher.nix
    ];

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

  services.avahi.enable = true;
  services.avahi.nssmdns = true;
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

  services.bitlbee = { enable = true;
                       plugins = with pkgs; [ bitlbee-facebook ];
                     };

  services.toxvpn = { enable = true;
                      localip = "10.0.0.10";
                    };

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.xserver.layout = "dvorak";
  services.xserver.xkbOptions = "caps:escape";
  services.xserver.displayManager.slim = {
    enable = true;
    autoLogin = false;
    defaultUser = "toonn";
  };
  services.xserver.windowManager.xmonad.enable = false;
  services.xserver.windowManager.openbox.enable = true;

  # Enable touchpad support.
  services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.toonn = {
    extraGroups = [ "wheel" ];
    isNormalUser = true;
    shell = pkgs.fish;
  };

  system.stateVersion = "19.03"; # ID10-t
}
