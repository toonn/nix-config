{ config, pkgs, lib, ... }:
{
  imports =
    [
      ./hardware-configuration.nix
    ];

  nixpkgs.config = { allowUnfree = true; };

  # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.device = "/dev/sda";

  boot.kernelParams = [ "cryptdevice=/dev/sda2:cruithne_vg"
                        "crypto=ripemd160:\"aes-cbc-essiv:sha256\":256:0:"
                      ];
  boot.initrd.extraUtilsCommands = ''
    copy_bin_and_libs ${pkgs.cryptsetup}/bin/cryptsetup
    '';
  boot.initrd.extraUtilsCommandsTest = ''
    $out/bin/cryptsetup --version
    '';
  boot.initrd.kernelModules = [ "dm-crypt" "cbc" ];
  boot.initrd.preLVMCommands = ''
    /bin/cryptsetup --type plain open /dev/sda2 cruithne_vg
    '';
  boot.initrd.supportedFilesystems = [ "btrfs" ];

  fileSystems."/".options = [ "compress=lzo" ];
  fileSystems."/home".options = [ "compress=lzo" ];

  hardware.enableAllFirmware = true;
  hardware.cpu.intel.updateMicrocode = true;

  nix.buildCores = 1;
  nix.maxJobs = 1;

  networking.hostName = "cruithne";
  networking.wireless.enable = true;  # Enables wpa_supplicant.

  i18n = {
    consoleFont = "Lat2-Terminus16";
    consoleKeyMap = "dvorak";
    defaultLocale = "en_DK.UTF-8";
  };

  time.timeZone = "Europe/Amsterdam";

  environment.shells = with pkgs; [ fish ];

  environment.systemPackages = with pkgs; [
    vim
    cryptsetup
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = { enable = true; enableSSHSupport = true; };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;

  services.avahi.enable = true;
  services.avahi.nssmdns = true;

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
