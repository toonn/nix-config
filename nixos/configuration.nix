{ config, pkgs, lib, ... }:
let nix-config-repo = /home/toonn/src/nix-config;
in {
  disabledModules = [ "services/backup/borgbackup.nix"
                      "services/networking/bitlbee.nix"
                      "services/hardware/actkbd.nix"
                    ];
  imports =
    [ /etc/nixos/hardware-configuration.nix
      <home-manager/nixos>
      (nix-config-repo + "/modules/borgbackup/borgbackup.nix")
      # (builtins.fetchurl { url = "https://raw.githubusercontent.com/NixOS/nixpkgs/f4c69e198ce8a8208995e43133d4c32d2045a587/nixos/modules/services/networking/bitlbee.nix"; sha256 = "1d120xrhq6hzn2rnhqh69dzs4gy6wb5pywni13ir4ldkrxfx40yw"; })
      (nix-config-repo + "/modules/bitlbee.nix")
      (nix-config-repo + "/modules/mdns-publisher.nix")
      /home/toonn/src/nixpkgs/actkbd-user-module/nixos/modules/services/hardware/actkbd.nix
    ];

  nix = {
    # buildMachines = [ { hostName = "darwin-build-box.winter.cafe";
    #                     maxJobs = 4;
    #                     sshKey = "/home/toonn/.ssh/darwin-build-box_id_ed25519";
    #                     sshUser = "toonn";
    #                     systems = [ "aarch64-darwin" "x86_64-darwin" ];
    #                   }
    #                   { hostName = "darwin-build-box.nix-community.org";
    #                     maxJobs = 4;
    #                     sshKey = "/home/toonn/.ssh/darwin-build-box_id_ed25519";
    #                     sshUser = "toonn";
    #                     systems = [ "aarch64-darwin" "x86_64-darwin" ];
    #                   }
    #                 ];
    # distributedBuilds = true;
    settings = {
      cores = 1;
      max-jobs = 1;
      extra-trusted-public-keys = [
        # Haskell.nix cache
        "hydra.iohk.io:f/Ea+s+dFdN+3Y/G+FDgSq+a5NEWhJGzdjvKNGv0/EQ="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
      extra-substituters = [
        "https://cache.iog.io?priority=50" # Prefer nixos.org
        "https://nix-community.cachix.org?priority=49"
      ];
    };
  };

  nixpkgs = {
    config = {
      allowUnfreePredicate = p: builtins.elem (pkgs.lib.getName p) [
        "broadcom-sta"
        "joypixels"
      ];
      joypixels.acceptLicense = true;
    };

    overlays = [
      # (import (nix-config-repo + "/overlays/bitlbee.nix"))
      (import (nix-config-repo + "/overlays/libinput.nix"))
      (import (nix-config-repo + "/overlays/mdns-publisher.nix"))
      (import (nix-config-repo + "/overlays/nssmdns.nix"))
      (import (nix-config-repo + "/overlays/purple-matrix.nix"))

      # # Temporarily trying to debug subdomain resolution by nsncd
      # ( self: super: {
      #     nsncd = super.nsncd.overrideAttrs (oAs: {
      #       cargoBuildType = "debug";
      #       patches = oAs.patches ++ [ /home/toonn/handlers.diff ];
      #     });
      #   }
      # )
    ];
  };

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Aqprox WiFi adapter, RTL8811AU chip
  boot.extraModulePackages = with config.boot.kernelPackages; [
    rtl88xxau-aircrack
  ];

  fileSystems."/".options = [ "compress=zstd" ];

  fonts.packages = with pkgs; [ joypixels ];

  hardware.cpu.intel.updateMicrocode = true;

  hardware.firmware = [
    # To get the webcam working
    # Got iSight.fw from https://archive.org/details/macbook-isight-webcam-linux
    ( pkgs.runCommandNoCC "isight-webcam" {} ''
        install -D ${./isight.fw} $out/lib/firmware/isight.fw
      ''
    )
  ];

  networking.hostName = "yorp";
  # Connman instead
  # networking.wireless = { enable = true;  # Enables wpa_supplicant.
  #                         interfaces = [ "wls4" ];
  #                       };
  networking.networkmanager.enable = true;

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
    xkb = {
      layout = "us";
      variant = "dvorak";
      options = "caps:escape,compose:rwin";
    };
    displayManager = { defaultSession = "none+openbox";
                       lightdm = { enable = true;
                                   greeters.mini = { enable = true;
                                                     user = "toonn";
                                                   };
                                 };
                     };
    windowManager.openbox.enable = true;
    # Enable touchpad support (enabled default in most desktopManager).
    libinput = { enable = true;
                 touchpad.naturalScrolling = true;
               };
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Smart card reader support
  services.pcscd.enable = true;

  # Enable sound.
  # # This enables ALSA, unless hardware.pulseaudio is enabled.
  # sound.enable = true;
  # # This replaces ALSA with PulseAudio
  # hardware.pulseaudio.enable = true;
  services.pipewire = { audio.enable = true;
                        enable = true;
                        pulse.enable = true;
                      };

  users.users.toonn = {
    extraGroups = [ "wheel" "networkmanager" ]; # Enable ‘sudo’ for the user.
    isNormalUser = true;
    shell = with pkgs; fish;
  };

  home-manager.users.toonn = import /home/toonn/.config/nixpkgs/home.nix;

  # NixOS doesn't facilitate setting up systemd user generators
  environment = {
    etc = {
    #   "systemd/user-generators/user-actkbd.generator".source
    #     = pkgs.writeShellScript "user-actkbd-systemd.generator" ''
    #         mkdir -p "$1"/default.target.wants
    #         for device in $(realpath /dev/input/by-path/*-kbd); do
    #           # In principle it's possible to use systemd-escape's --path
    #           # option here but this would require running systemd-escape from
    #           # the corresponding udev rule and the shorter execution of a udev
    #           # rule is, the better.
    #           instance=$(systemd-escape --template=user-actkbd@.service \
    #                        "$device" \
    #                     )
    #           ln -s /etc/systemd/user/user-actkbd@.service \
    #             "$1"/default.target.wants/"$instance"
    #         done
    #       '';

    # A libinput quirk was added for the single button MacBook touchpad (to be
    # released in 1.26). However, this prevents dragging with multiple fingers
    # by pressing down on the touchpad button. Making the touchpad button near
    # useless. I prefer it keep behaving as a "clickpad" so I'm overriding that
    # quirk locally.
    "libinput/local-overrides.quirks".text = ''
      [Apple Touchpad OneButton A1181]
      MatchUdevType=touchpad
      MatchBus=usb
      MatchVendor=0x05AC
      MatchProduct=0x022A
      ModelAppleTouchpadOneButton=0
      AttrInputProp=+INPUT_PROP_BUTTONPAD
    '';

    # nscd doesn't allow subdomains unless the heuristics are disabled by
    # explicitly allowing certain domains.
    # nsncd does not appear to be respecting this configuration file.
      "mdns.allow".text = ''
        .local.
        .local
      '';
    };
    shells = with pkgs; [ fish ];
    systemPackages = with pkgs; [
      vim
    ];
  };

  # Otherwise errors about users.toonn.shell being set to fish, even though the
  # shell and therefore the Nix paths are set up by HM.
  programs.fish.enable = true;

  # Enable screen bright fn keys together with services.actkbd
  programs.light.enable = true;

  # Darwin-build-box public key fingerprint
  programs.ssh.knownHosts."darwin-build-box.winter.cafe".publicKey =
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIB0io9E0eXiDIEHvsibXOxOPveSjUPIr1RnNKbUkw3fD";
  # Community Darwin builder
  programs.ssh.knownHosts."darwin-build-box.nix-community.org".publicKey =
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFz8FXSVEdf8FvDMfboxhB5VjSe7y2WgSa09q1L4t099";

  # Bind fn brightness keys to light utility commands
  services.actkbd = {
    # /dev/input/event7 seems to be the keyboard
    bindings = let light = "${lib.getBin pkgs.light}/bin/light";
                in [ { keys = [ 224 ];
                       events = [ "key" ];
                       command = "${light} -U 5";
                     }
                     { keys = [ 225 ];
                       events = [ "key" ];
                       command = "${light} -A 5";
                     }
                   ];
    enable = true;
    user.bindings = let wpctl = "${lib.getBin pkgs.wireplumber}/bin/wpctl";
                     in [
                # Ungrab on release events because X drivers sometimes interpret
                # a release as both a press and a release.
                # Used /dev/input/event8 to get the keycodes.
                { keys = [ 113 ];
                  events = [ "key" ];
                  # attributes = [ "ungrabbed" "grab" "exec" ];
                  # command = "/run/current-system/sw/bin/pactl set-sink-mute @DEFAULT_SINK@ toggle";
                  command = "${wpctl} set-mute @DEFAULT_SINK@ toggle";
                }
                # { keys = [ 113 ];
                #   events = [ "rel" ];
                #   attributes = [ "grabbed" "ungrab" "noexec" ];
                # }
                { keys = [ 114 ];
                  events = [ "key" ];
                  # attributes = [ "ungrabbed" "grab" "exec" ];
                  # command = "/run/current-system/sw/bin/pactl set-sink-volume @DEFAULT_SINK@ -10%";
                  command = "${wpctl} set-volume @DEFAULT_SINK@ 10%-";
                }
                # { keys = [ 114 ];
                #   events = [ "rel" ];
                #   attributes = [ "grabbed" "ungrab" "noexec" ];
                # }
                { keys = [ 115 ];
                  events = [ "key" ];
                  # attributes = [ "ungrabbed" "grab" "exec" ];
                  # command = "/run/current-system/sw/bin/pactl set-sink-volume @DEFAULT_SINK@ +10%";
                  # Might want to add `--limit 1.0`
                  command = "${wpctl} set-volume @DEFAULT_SINK@ 10%+";
                }
                # { keys = [ 115 ];
                #   events = [ "rel" ];
                #   attributes = [ "grabbed" "ungrab" "noexec" ];
                # }
              ];
  };

  # # Volume control with actkbd and pactl/wpctl needs to run as a user unit.
  # # Based on PR #67227, https://github.com/NixOS/nixpkgs/pull/67227
  # services.udev.packages = lib.mkForce (lib.singleton
  #   ( pkgs.writeTextFile {
  #       name = "actkbd-udev-rules";
  #       destination = "/etc/udev/rules.d/61-actkbd.rules";
  #       text = let actkbdVar = "actkbd@$env{DEVNAME}.service";
  #               in ''
  #                    ACTION=="add", \
  #                    SUBSYSTEM=="input", \
  #                    KERNEL=="event[0-9]*", \
  #                    ENV{ID_INPUT_KEY}=="1", \
  #                    TAG+="systemd", \
  #                    TAG+="uaccess",${ # Necessary for user services to get
  #                                      # access to the input device. I tried
  #                                      # setting MODE=0444 but this made both
  #                                      # user and system services fail.
  #                                      # Note: Udev rules don't support in-line
  #                                      #       comments so this is a sneaky way
  #                                      #       to do so.
  #                                      ""
  #                                    } \
  #                    ENV{SYSTEMD_WANTS}+="${actkbdVar}", \
  #                    ENV{SYSTEMD_USER_WANTS}+="user-${actkbdVar}"
  #                  '';
  #     }
  #   )
  # );

  # # Usually these'd be managed by HM but I consider media keys to be a
  # # responsibility for the system.
  # systemd.user.services = {
  #   "user-actkbd@" = {
  #     # Can't set this to false because then the template and the instances end
  #     # up as masked in systemctl
  #     # enable = false; # Senseless for a template.
  #     restartIfChanged = false; # Senseless for a template.
  #     serviceConfig = {
  #       Type = "simple";
  #       ExecStart =
  #         let wpctl = "${lib.getBin pkgs.wireplumber}/bin/wpctl";
  #             bindings = [
  #               # Ungrab on release events because X drivers sometimes interpret
  #               # a release as both a press and a release.
  #               # Used /dev/input/event8 to get the keycodes.
  #               { keys = [ 113 ];
  #                 events = [ "key" ];
  #                 # attributes = [ "ungrabbed" "grab" "exec" ];
  #                 # command = "/run/current-system/sw/bin/pactl set-sink-mute @DEFAULT_SINK@ toggle";
  #                 command = "${wpctl} set-mute @DEFAULT_SINK@ toggle";
  #               }
  #               # { keys = [ 113 ];
  #               #   events = [ "rel" ];
  #               #   attributes = [ "grabbed" "ungrab" "noexec" ];
  #               # }
  #               { keys = [ 114 ];
  #                 events = [ "key" ];
  #                 # attributes = [ "ungrabbed" "grab" "exec" ];
  #                 # command = "/run/current-system/sw/bin/pactl set-sink-volume @DEFAULT_SINK@ -10%";
  #                 command = "${wpctl} set-volume @DEFAULT_SINK@ 10%-";
  #               }
  #               # { keys = [ 114 ];
  #               #   events = [ "rel" ];
  #               #   attributes = [ "grabbed" "ungrab" "noexec" ];
  #               # }
  #               { keys = [ 115 ];
  #                 events = [ "key" ];
  #                 # attributes = [ "ungrabbed" "grab" "exec" ];
  #                 # command = "/run/current-system/sw/bin/pactl set-sink-volume @DEFAULT_SINK@ +10%";
  #                 # Might want to add `--limit 1.0`
  #                 command = "${wpctl} set-volume @DEFAULT_SINK@ 10%+";
  #               }
  #               # { keys = [ 115 ];
  #               #   events = [ "rel" ];
  #               #   attributes = [ "grabbed" "ungrab" "noexec" ];
  #               # }
  #             ];
  #             config = pkgs.writeText "actkbd.conf" ''
  #               ${lib.concatMapStringsSep "\n"
  #                 ( { keys, events ? [], attributes ? [], command ? "" }:
  #                 ''${lib.concatMapStringsSep "+" toString keys}:${
  #                     lib.concatStringsSep "," events}:${
  #                     lib.concatStringsSep "," attributes}:${
  #                     command
  #                   }''
  #                 )
  #                 bindings
  #               }
  #             '';
  #          in "${pkgs.actkbd}/bin/actkbd -c ${config} -d %I";
  #     };
  #     unitConfig = {
  #       After = [ "default.target" ];
  #       Description = "actkbd on %I";
  #       ConditionPathExists = "%I";
  #     };
  #   };
  # };

  services.avahi = { # allowPointToPoint = true;
                     enable = true;
                     ipv6 = false;
                     # This adds mdns_minimal, which only works for 169.254.x.x
                     # and not subdomains, dropping in favor of adding mdns4 to
                     # nsswitch hosts manually.
                     # nssmdns = true;
                     publish = { enable = true;
                                 addresses = true;
                                 # Needed for mdns-publiher
                                 # userServices = true;
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
                         persistentTimer = true;
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

  services.flatpak.enable = true;
  # Requirement for Flatpak
  xdg.portal = { enable = true;
                 config.common = { default = "gtk"; };
                 extraPortals = with pkgs; [ xdg-desktop-portal-gtk ];
               };

  # Default conflicts with connman
  networking.dhcpcd.enable = false;

  #networking.wireless.enable = true;

  #services.connman = { enable = true;
  #                     #enableVPN = false; # default enabled as a test
  #                     # wpa_supplicant issue should be fixed in 21.11
  #                     # Doesn't seem to be fixed in 21.11
  #                     #wifi.backend = "iwd";
  #                   };

  services.mdns-publisher.names =
    map (sub: sub + ".${config.networking.hostName}.local")
        [ "32p"
          "ggn"
          "immich"
          "ipt"
          "mam"
          "mercury"
          "nix-cache"
          "pb"
          "photoprism"
          "pluto"
          "selfoss"
          "vermaelens-projects"
        ];

  services.openssh.enable = true;

  networking.firewall.allowedTCPPorts = [ 80 ];
  services.nginx = {
    enable = true;
    upstreams.sol.servers = {
      "100.111.249.9" = {};
      "10.0.0.5".backup = true;
    };
    virtualHosts = {
      "*.yorp.local" = {
        extraConfig = ''
          default_type application/json;

          location / {
            proxy_buffering off;
            proxy_pass http://sol;
            fastcgi_read_timeout 120;
            proxy_set_header Host $host;
          }
        '';
      };
    };
  };

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
