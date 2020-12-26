{ config, pkgs, ... }:
{ # Let Home Manager install and manage itself.
  # programs.home-manager.enable = true;

  nixpkgs.config = {
    allowUnfreePredicate = p: builtins.elem (pkgs.stdenv.lib.getName p) [
      "ffmpeg-full"
      "Firefox"
      "openemu"
      "unrar"
      ];
    #overlays = [
    #  (import ~/.config/nixpkgs/overlays/firefox.nix)
    #  ];
    packageOverrides = pkgs: {
      nur = import (builtins.fetchTarball
        "https://github.com/nix-community/NUR/archive/master.tar.gz") {
          inherit pkgs;
        };
    };
    permittedInsecurePackages = [
        "openssl-1.0.2u"
      ];
    zathura.useMupdf = true;
  };

  home.activation.linkDotfiles = config.lib.dag.entryAfter [ "writeBoundary" ]
    ''
      ln -sfn $HOME/src/dotfiles/bin  $HOME/bin
      ln -sfn $HOME/src/dotfiles/opt  $HOME/opt
      ln -sfn $HOME/src/dotfiles/tmux $HOME/.tmux
      ln -sfn $HOME/src/dotfiles/vim  $HOME/.vim
      ln -sfn $HOME/src/dotfiles/fish/functions \
        $HOME/.config/fish/functions
      ln -sfn $HOME/src/dotfiles/kitty \
        $HOME/.config/kitty
      ln -sfn $HOME/src/dotfiles/mpv/scripts \
        $HOME/.config/mpv/scripts
      ln -sfn $HOME/src/dotfiles/ranger \
        $HOME/.config/ranger
    '';

  home.activation.linkApps = config.lib.dag.entryAfter [ "writeBoundary" ]
    (pkgs.stdenv.lib.strings.optionalString pkgs.stdenv.isDarwin
      ''
        for app in $HOME/.nix-profile/Applications/*.app;
        do ln -sf $app $HOME/ApplicationsNix;
        done
        # Karabiner's Lib needs to be in /Library : /
        # for d in $HOME/.nix-profile/Library/*;
        #   do mkdir -p $HOME/"''${d''\#$HOME/.nix-profile/}"
        #      for f in "$d"/*;
        #        do ln -sf "$f" $HOME/"''${d''\#$HOME/.nix-profile/}"; done
        #   done
        # for d in $HOME/.nix-profile/Library/*;
        #   do mkdir -p /"''${d''\#$HOME/.nix-profile/}"
        #      for f in "$d"/org.pqrs*;
        #        do sudo ln -sf "$f" /"''${d''\#$HOME/.nix-profile/}"; done
        #   done
      '');

  home.file = { # "bin".source = ~/src/dotfiles/bin;
                # "opt".source = ~/src/dotfiles/opt;
                # ".config/fish/functions".source =
                #   ~/src/dotfiles/fish/functions;
                # ".config/kitty".source = ~/src/dotfiles/kitty;
                # ".config/mpv/scripts".source = ~/src/dotfiles/mpv/scripts;
                # ".config/nix/nix.conf".source = ./dotfiles/nix/nix.conf;
                # ".config/ranger/rc.conf".source = ./dotfiles/ranger/rc.conf;
                # ".config/ranger/rifle.conf".source =
                #   ./dotfiles/ranger/rifle.conf;
                # ".config/ranger/commands.py".source =
                #   ./dotfiles/ranger/commands.py;
                # ".config/ranger/scope.sh".source = ./dotfiles/ranger/scope.sh;
                # ".vim" = ~/src/dotfiles/vim;
              };

  home.packages = let provideApp = app:
                        if pkgs.stdenv.isDarwin
                          then (pkgs.buildEnv { name = "${app.name}-App";
                                                paths = [
                                                    app
                                                  ];
                                                pathsToLink = [
                                                    "/Applications"
                                                    "/bin"
                                                    "/Library"
                                                    "/share"
                                                  ];
                                               }
                               )
                          else app;
    in with pkgs;
       [ # anki
         arbtt
         bfpt
         cdrtools
         coldasdice
         curl
         entr
         fd
         (ffmpeg-full.override { libopus = libopus;
                                 lame    = lame;
                                 nonfreeLicensing = true;
                                 fdkaacExtlib     = true;
                                 fdk_aac          = fdk_aac;
                               })
         gist
         gnupg
         # ifuse
         imgursh
         inkscape
         irssi
         # karabiner-elements
         kitty
         moreutils
         mupdf
         (pass.withExtensions (exts: with exts; [ pass-otp ]))
         popcorntime
         ranger
         ripgrep
         rsync
         sshuttle
         time
         toxvpn
         unrar
         wire-desktop
         youtube-dl
         zbar
       ] ++ (if pkgs.stdenv.isDarwin
             then [ openemu
                    (vim_configurable.override { darwinSupport = true;
                                                 guiSupport = "no";
                                                 netBeansSupport = false;
                                               })
                  ]
             else []);

  home.sessionVariables =
    let common = {
            # COLUMNS = 80;
            EDITOR = "vim";
            # LS_COLORS = "";
            # RANGER_LOAD_DEFAULT_RC = "FALSE";
            SHELL = "fish";
            VISUAL = "vim";
          };
        linux = common // {
            # LANG = "en_DK.UTF-8";
            SYSTEMD_EDITOR = "vim";
          };
        darwin = common // {
            LANG           = "en_US.UTF-8";
            LC_CTYPE       = "en_US.UTF-8";
            LC_MEASUREMENT = "nl_BE.UTF-8";
            LC_PAPER       = "nl_BE.UTF-8";
            LC_TIME        = "nl_BE.UTF-8";
          };
    in if pkgs.stdenv.isDarwin
      then darwin
      else linux;

  programs.direnv = { enable = true;
                      enableFishIntegration = true;
                      # config = { };
                      # stdlib = "";
                    };

  programs.firefox = {
    enable = true;
    enableAdobeFlash = false;
    package = pkgs.firefox-app;
    extensions = with pkgs.nur.repos.rycee.firefox-addons;
      [
        darkreader
        decentraleyes
        multi-account-containers
        #google-search-link-fix  # ClearURLs is a better alternative
        https-everywhere
        pkgs.clearurls  # Missing from rycee's addons Overlay
        #saka-key  # Missing from rycee's addons Delisted from addon marketplace
        temporary-containers
        ublock-origin
        vimium
      ];
    profiles = {
      "cmyk" = {
        id = 0;
        isDefault = true;
        name = "tonerlow";
        path = "notonercartridge";
        settings = import ~/src/nix-config/home/ff-userjs.nix;
        userChrome = builtins.readFile
          ~/src/dotfiles/ff-conf/chrome/userChrome.css;
        userContent = builtins.readFile
          ~/src/dotfiles/ff-conf/chrome/userContent.css;
      };
    };
  };

  programs.fish = { enable = true;
                    package = pkgs.fish;
                    # shellInit = ''
                    #     if set -l ind \
                    #          ( contains -i -- \
                    #              /nix/var/nix/profiles/per-user/root/channels \
                    #              $NIX_PATH \
                    #          )
                    #       set -e NIX_PATH[$ind]
                    #     end
                    #   '';
                  };
  
  programs.git = { enable = true;
                   package = pkgs.git;
                   aliases =
                     { lg = "log --graph --pretty=format:'%C(auto)%h -%d %s"
                          + " %Cgreen(%cr) %C(bold blue)<%an>%Creset'";
                       st = "status -sb";
                     };
                   ignores =
                     [ # Swap
                       "[._]*.s[a-v][a-z]"
                       "[._]*.sw[a-p]"
                       "[._]s[a-rt-v][a-z]"
                       "[._]ss[a-gi-z]"
                       "[._]sw[a-p]"

                       # Session
                       "Session.vim"
                       "Sessionx.vim"

                       # Temporary
                       ".netrwhist"
                       "*~"
                       # Auto-generated tag files
                       "tags"

                       # Persistent undo
                       "[._]*.un~"

                       # Direnv
                       ".direnv"
                       ".envrc"

                       # OS generated files
                       ".DS_Store"
                       "ehthumbs.db"
                       "Icon?"
                       "Thumbs.db"
                     ];
                   # signing = null;
                   userEmail = "toonn@toonn.io";
                   userName = "toonn";
                 };

  programs.info.enable = true;

  # programs.irssi = { enable = true;
  #                    aliases = { };
  #                    networks =
  #                      { freenode =
  #                          { autoCommands = [ ];
  #                            channels = { haskell.autoJoin = true;
  #                                       };
  #                            nick = "__monty__";
  #                            server = { address = "chat.freenode.net";
  #                                       autoConnect = true;
  #                                       ssl.enable = true;
  #                                       ssl.verify = true;
  #                                     };
  #                          };
  #                      };
  #                  };

  programs.mpv =
    { enable = true;
      bindings =
        { "ESC"              = "quit";
          "I"                =
            "show_text \"\${media-title}\"           # display media-title in osd";
          "F"                =
            "show_text \"\${filename}\"              # display filename in osd";
          "("                = "add volume -20";
          ")"                = "add volume +20";
          "g"                = "add sub-scale -0.1";
          "G"                = "add sub-scale +0.1";
          "Alt+RIGHT"        = "script-message Cycle_Video_Rotate 90";
          "Alt+LEFT"         = "script-message Cycle_Video_Rotate -90";
          "Ctrl+Shift+LEFT"  = "add video-pan-x +0.01";
          "Ctrl+Shift+RIGHT" = "add video-pan-x -0.01";
          "Ctrl+Shift+UP"    = "add video-pan-y +0.01";
          "Ctrl+Shift+DOWN"  = "add video-pan-y -0.01";
          "Alt+-"            = "add video-zoom -0.25";
          "Alt+="            = "add video-zoom 0.25";
          "Alt+UP"           = "vf toggle mirror"; # s/mirror/hflip ?
          "Alt+BS"           = "playlist-remove current";
          "Ctrl+Alt+-"       = "add window-scale -0.5";
          "Ctrl+Alt++"       = "add window-scale +0.5";
        };
       config = { osc             = "no";
                  volume-max      = "600";
                  af              = "scaletempo";
                  sub-auto        = "fuzzy";
                  slang           = "eng,en";
                  alang           = "eng,en";
                  border          = "no";
                  ytdl-format     =
                    "best #bestvideo[height<=?720]+bestaudio/best";
                  osd-font        = "'Source Sans Pro'";
                  osd-font-size   = 40;
                  # sub-scale       = 0.6;
                  sub-font-size   = 27; # default 55
                  sub-border-size = 1.5; # default 3
                  title           = "\${path}"; # for arbtt
                };
       # profiles = { fast = { vo = "vdpau"; }; };
    };

  programs.ssh =
    { enable = true;
      # extraConfig = "";
      # extraOptionOverrides = { };
      matchBlocks = { "g5" = { hostname = "192.168.0.9";
                               user     = "toon";
                             };
                      # From titan:
                      # "cs" = { hostname     = "st.cs.kuleuven.be";
                      #          user         = "r0258654";
                      #          identityFile = "~/.ssh/cs_id_rsa";
                      #        };
                      # From terra:
                      "cs" = { hostname = "st.cs.kuleuven.be";
                               user = "r0258654";
                               identityFile = [ "~/.ssh/cs_kuleuven_id_rsa"
                                                "~/.ssh/cs_kuleuven_id_dsa" ];
                               extraOptions = { preferredAuthentications =
                                                  "publickey,password";
                                              };
                             };
                      # From titan:
                      # "github" = { hostname     = "github.com";
                      #              user         = "git";
                      #              identityFile = "~/.ssh/github_id_rsa";
                      #            };
                      # From terra:
                      "github" = { hostname = "github.com";
                                   user = "git";
                                   identityFile = "~/.ssh/terra_gh_id_ed25519";
                                   extraOptions = { preferredAuthentications =
                                                      "publickey";
                                                  };
		                 };
                      "gist" = { hostname     = "gist.github.com";
                                 user         = "git";
                                 identityFile = "~/.ssh/github_id_rsa";
                               };
                      "gho" = { hostname = "gitlab.haskell.org";
                                user = "git";
                                identityFile = "~/.ssh/terra_gho_id_ed25519";
                              };
                      "gfo" = { hostname = "gitlab.freedesktop.org";
                                user = "git";
                                identityFile = "~/.ssh/terra_gfo_id_ed25519";
                              };
                      "sol" = { hostname     = "sol.local";
                                user         = "toonn";
                                identityFile = "~/.ssh/nix_id_ed25519";
                              };
                      # From titan:
                      # "toxsol" = { hostname     = "10.0.0.5";
                      #              user         = "toonn";
                      #              identityFile = "~/.ssh/nix_id_ed25519";
                      #            };
                      "son" = { hostname     = "sons-imac.local";
                                user         = "toonn";
                                identityFile = "~/.ssh/titan_id_ed25519";
                              };
                      "titan" = { hostname = "titan.local";
                                  extraOptions = { preferredAuthentications =
                                                     "publickey,password";
                                                 };
                                };
                      "helium" = { hostname = "ssh.esat.kuleuven.be";
                                   user = "r0258654";
                                 };
                      "lint" = { hostname = "localhost";
                                 port = 2222;
                                 user = "r0258654";
                                 extraOptions = { hostKeyAlias = "lint"; };
                               };
                    };
    };

  # programs.texlive = { enable = true;
  #                      package = pkgs.texlive;
  #                      extraPackages = tpkgs:
  #                        { inherit (tpkgs) collection-fontsrecommended
  #                          algorithms;
  #                        };
  #                    };

  programs.tmux = { enable = true;
                    package = pkgs.tmux;
                    aggressiveResize = true;
                    clock24 = true;
                    # disableConfirmationPrompt = true;
                    extraConfig = ''
                      set -g allow-rename on
                      set -ga terminal-overrides ",xterm-kitty:Tc"
                    '';
                    plugins = [ pkgs.tmuxPlugins.sensible ];
                    secureSocket = false;
                    terminal = "screen-256color";
                  };

  # programs.vim = { enable = true;
  #                  # extraConfig = "";
  #                  # plugins = [ "" ];
  #                  # settings = { };
  #                };

  programs.zathura = { enable = true;
                       # options = { default-bg = "#000000";
                       #             default-fg = "#FFFFFF";
                       #           };
                     };

  # services.dunst =
  #   { enable = true;
  #     # iconTheme = { name = "hicolor";
  #     #               package = pkgs.gnome3.hicolor-icon-theme;
  #     #               size = "32x32";
  #     #             };
  #     settings =
  #       { global =
  #           { monitor = 0
  #             follow = "mouse";
  #             geometry = "300x5-15+30";
  #             indicate_hidden = "yes";
  #             shrink = "no";
  #             transparency = 0
  #             notification_height = 0
  #             separator_height = 2
  #             padding = 8
  #             horizontal_padding = 8
  #             frame_width = 3
  #             frame_color = "#aaaaaa";
  #             separator_color = "frame";
  #             sort = "yes";
  #             idle_threshold = 120
  #             font = Monospace 12
  #             line_height = 0
  #             markup = "full";
  #             format = "<b>%s</b>\\n%b";
  #             alignment = "left";
  #             show_age_threshold = 60
  #             word_wrap = "yes";
  #             ellipsize = "middle";
  #             ignore_newline = "no";
  #             stack_duplicates = "true";
  #             hide_duplicate_count = "false";
  #             show_indicators = "yes";
  #             icon_position = "left";
  #             max_icon_size = 64
  #             icon_path = "/usr/share/icons/Adwaita/16x16/status/"
  #                       + ":/usr/share/icons/Adwaita/16x16/devices/";
  #             sticky_history = "yes";
  #             history_length = 20
  #             dmenu = "dmenu -p dunst:";
  #             browser = "firefox -new-tab";
  #             always_run_script = "true";
  #             title = "Dunst";
  #             class = "Dunst";
  #             startup_notification = "false";
  #             force_xinerama = "false";
  #           };
  #         experimental = { per_monitor_dpi = "false" };
  #         shortcuts =
  #           { close = "ctrl+space";
  #             close_all = "ctrl+shift+space";
  #             history = "ctrl+grave";
  #             context = "ctrl+shift+period";
  #           };
  #         urgency_low =
  #           { background = "#222222";
  #             foreground = "#888888";
  #             timeout = 10
  #           };
  #         urgency_normal =
  #           { background = "#285577";
  #             foreground = "#ffffff";
  #             timeout = 10
  #           };
  #         urgency_critical =
  #           { background = "#900000";
  #             foreground = "#ffffff";
  #             frame_color = "#ff0000";
  #             timeout = 0
  #           };
  #       };
  #   };

  # services.gpg-agent = { enable = true;
  #                        enableSshSupport = true;
  #                        sshKeys = [ "" ];
  #                      };

  # services.redshift = { enable = true;
  #                       package = pkgs.redshift;
  #                       brightness.day = 1.0;
  #                       brightness.night = 0.1;
  #                       extraOptions = [ "-g 0.8"
  #                                        "-m randr"
  #                                      ];
  #                       latitude = 51.3;
  #                       longitute = 4.88;
  #                       provider = "manual";
  #                       temperature.day = 5700;
  #                       temperature.night = 3300;
  #                       tray = true;
  #                     };

  # services.systemd.user.services =
  #   { Unit =
  #       { Description = "Dunst notification daemon";
  #         Documentation = [ "man:dunst(1)" ];
  #         PartOf = "graphical-session.target";
  #       };
  #     Service =
  #       { Type = "dbus";
  #         BusName = "org.freedesktop.Notifications";
  #         ExecStart =
  #         "/nix/store/whpc8sskirj7f9hkvsd3grwawbz4270f-dunst-1.4.0/bin/dunst";
  #       };
  #     Install =
  #       { WantedBy = "default.target"; };
  #   };
}
