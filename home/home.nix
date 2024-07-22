{ config, pkgs, lib, ... }:
{ nixpkgs = {
    config = {
      allowUnfreePredicate = p: builtins.elem (lib.getName p) [
        "ffmpeg-full"
        "Firefox"
        "firefox-bin"
        "firefox-release-bin-unwrapped"
        "openemu"
        "teensy-udev-rules"
        "unrar"
      ];
      packageOverrides = pkgs: {
        nur = import ( builtins.fetchTarball
                "https://github.com/nix-community/NUR/archive/master.tar.gz"
              ) { inherit pkgs; };
      };
      permittedInsecurePackages = [
        "openssl-1.0.2u"
      ];
      zathura.useMupdf = true;
    };

    overlays = [
      (import /home/toonn/src/nix-config/overlays/firefox-addons.nix)
      # (import /home/toonn/src/nix-config/overlays/haskell-packages.nix)
      (import /home/toonn/src/nix-config/overlays/mpvScripts.nix)
      (import /home/toonn/src/nix-config/overlays/taskell.nix)
    ];
  };

  home.username = "toonn";

  home.homeDirectory = let userDir = if pkgs.stdenv.isDarwin
                                     then "Users"
                                     else "home";

                        in"/${userDir}/${config.home.username}";

  # Caveat Emptor: Changing stateVersion may require manual data
  #                conversion or moving of files.
  home.stateVersion = "22.11";

  home.activation.linkDotfiles = config.lib.dag.entryAfter [ "writeBoundary" ]
    ''
      ln -sfn $HOME/src/dotfiles/bin            $HOME/bin
      ln -sfn $HOME/src/dotfiles/opt            $HOME/opt
      ln -sfn $HOME/src/dotfiles/tmux           $HOME/.tmux
      ln -sfn $HOME/src/dotfiles/vim            $HOME/.vim
      ln -sfn $HOME/src/dotfiles/fish/functions $HOME/.config/fish/functions
      ln -sfn $HOME/src/dotfiles/isync/mbsyncrc $HOME/.mbsyncrc
      ln -sfn $HOME/src/dotfiles/kitty          $HOME/.config/kitty
      ln -sfn $HOME/src/dotfiles/mailcap        $HOME/.mailcap
      mkdir -p $HOME/.config/mpv
      ln -sfn $HOME/src/dotfiles/mpv/scripts    $HOME/.config/mpv/scripts
      ln -sfn $HOME/src/dotfiles/neomutt        $HOME/.config/neomutt
      ln -sfn $HOME/src/dotfiles/notmuch/notmuch-config \
        $HOME/.notmuch-config
      ln -sfn $HOME/src/dotfiles/openbox        $HOME/.config/openbox
      ln -sfn $HOME/src/dotfiles/ranger         $HOME/.config/ranger
    '';

  home.file = let mozillaConfigPath =
                    if pkgs.stdenv.isDarwin
                    then "Library/Application Support/Mozilla"
                    else ".mozilla";
              in {
                # TODO: How does it work without this?
                # Including this prevents the browser extension from generating
                # a notification when FF starts up about not being able to find
                # the eID middleware.
                "${mozillaConfigPath}/managed-storage/belgiumeid@eid.belgium.be.json".source =
                  "${pkgs.eid-mw}/lib/mozilla/managed-storage/belgiumeid@eid.belgium.be.json";
                "${mozillaConfigPath}/pkcs11-modules/beidpkcs11.json".source =
                  "${pkgs.eid-mw}/lib/mozilla/pkcs11-modules/beidpkcs11.json";
                "${mozillaConfigPath}/pkcs11-modules/beidpkcs11_alt.json".source =
                  "${pkgs.eid-mw}/lib/mozilla/pkcs11-modules/beidpkcs11_alt.json";
                # "bin".source = ~/src/dotfiles/bin;
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
       [ anki
         alass
         bitwarden-cli
         curl
         direnv
         # eid-mw  # beID Middleware, paired with pcscd service for the readers
         entr
         fd
         gist
         # glirc # irc-core-2.11 marked as broken
         gnupg
         inkscape
         irssi
         isync # IMAP synchronization
         jq # Specifically for bitwarden
         kitty
         lorri
         moreutils
         mupdf
         neomutt
         niv
         notmuch
         (pass.withExtensions (exts: with exts; [ pass-otp ]))
         qmk
         ranger
         ripgrep
         rsync
         sequoia-sq
         sops
         sshuttle
         #taskell # needs bump on base bounds and compatibility with Brick 2.1.1
         time
         unrar
         (vim_configurable.override { darwinSupport = pkgs.stdenv.isDarwin;
                                      guiSupport = "no";
                                      netbeansSupport = false;
                                    })
         (import <nixos-unstable> {}).yt-dlp-light
         zbar
       ] ++ (with haskellPackages; [
         arbtt
       ]) ++ (if pkgs.stdenv.isDarwin
             then [ bfpt
                    cachix
                    cdrtools
                    coldasdice
                    dosage
                    (ffmpeg-full.override { libopus = libopus;
                                            lame    = lame;
                                            nonfreeLicensing = true;
                                            fdkaacExtlib     = true;
                                            fdk_aac          = fdk_aac;
                                          })
                    ifuse
                    imgursh
                    # karabiner-elements
                    kicad-app
                    openemu
                    popcorntime
                    toxvpn # Service on NixOS
                    wire-desktop
                  ]
             else [ ffmpeg
                    # tailscale # Not available on darwin, service on NixOS
                    teensy-udev-rules # Non-root programming of Teensy
                    unzip  # Vim needs unzip to browse ZIP archives
                    xclip
                  ]);

  home.sessionPath = [ "$HOME/bin" "$HOME/opt" ];

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

  xresources.properties = {
    "*faceName" = "DejaVu Sans Mono";
    "*faceSize" = 10;
    "*termName" = "xterm-256color";
    "*ttyModes" = "erase ^?";
    "*VT100.backarrowkey" = false;

    # Colorscheme based on accessiblepalette.com
    # set colors '#000000' '#fa4c35' '#27da3c' '#fecf49' '#3991cf' '#ff57ec' '#1ed1d1' '#dddddd' '#777777' '#ffa690' '#91e987' '#ffecba' '#75aadb' '#ff93f4' '#13ecec' '#ffffff'; for f in (seq -f %02g 0 15); for b in (seq -f %02g 0 15); hex $colors[(math $f + 1)] $colors[(math $b + 1)] "$f$b"; end; printf (tput sgr0)'\n'; end # Accessible base
    # Shortcomings: dark yellow, dark cyan, light magenta, contrast green on
    #               red
    "*VT100.color0"  = "#000000";
    "*VT100.color1"  = "#fa4c35";
    "*VT100.color2"  = "#27da3c";
    "*VT100.color3"  = "#fecf49";
    "*VT100.color4"  = "#3991cf";
    "*VT100.color5"  = "#ff57ec";
    "*VT100.color6"  = "#1ed1d1";
    "*VT100.color7"  = "#dddddd";
    "*VT100.color8"  = "#777777";
    "*VT100.color9"  = "#ffa690";
    "*VT100.color10" = "#91e987";
    "*VT100.color11" = "#ffef77"; # "#ffecba";
    "*VT100.color12" = "#75aadb";
    "*VT100.color13" = "#ff93f4";
    "*VT100.color14" = "#13ecec";
    "*VT100.color15" = "#ffffff";

    # # My Kitty colorscheme
    # "*VT100.color0"  = "#404040";
    # "*VT100.color8"  = "#666666";
    # #: black

    # "*VT100.color1"  = "#b75757";
    # "*VT100.color9"  = "#ce8d8d";
    # #: red

    # "*VT100.color2"  = "#87b757";
    # "*VT100.color10" = "#adce8d";
    # #: green

    # "*VT100.color3"  = "#b7b757";
    # "*VT100.color11" = "#cece8d";
    # #: yellow

    # "*VT100.color4"  = "#5777b7";
    # "*VT100.color12" = "#8da3ce";
    # #: blue

    # "*VT100.color5"  = "#b757b7";
    # "*VT100.color13" = "#ce8dce";
    # #: magenta

    # "*VT100.color6"  = "#57b7b7";
    # "*VT100.color14" = "#8dcece";
    # #: cyan

    # "*VT100.color7"  = "#dddddd";
    # "*VT100.color15" = "#ffffff";
    # #: white

    "*VT100.metaSendsEscape" = true;
    "*VT100*translations" = ''#override \n\
      Ctrl <Key>-: smaller-vt-font() \n\
      Ctrl <Key>+: larger-vt-font() \n\
      Ctrl Shift <Key>C: copy-selection(CLIPBOARD) \n\
      Ctrl Shift <Key>V: insert-selection(CLIPBOARD) \n\
      Alt <Key>I: set-reverse-video(toggle) \n\
    '';
  };

  programs.direnv = { enable = true;
                      # enableFishIntegration = true; # readonly option
                      # config = { };
                      # stdlib = "";
                    };

  programs.firefox = {
    enable = true;
    # TODO: Firefox is still missing eid-mw's managed-storage manifest
    package = pkgs.firefox-bin.override { pkcs11Modules = [ pkgs.eid-mw ]; };
    profiles = let
      extensions = with pkgs.nur.repos.rycee.firefox-addons;
        [
          bitwarden
          darkreader
          decentraleyes
          multi-account-containers
          #google-search-link-fix  # ClearURLs is a better alternative
          #https-everywhere  # Deprecated in favor of native https_only_mode
          #saka-key  # Missing from rycee's addons
          temporary-containers
          ublock-origin
          vimium
        ] ++ ( with pkgs; [
          belgium-eID  # Missing from rycee's addons Overlay
          clearurls  # Missing from rycee's addons Overlay
          custom-title  # Missing from rycee's addons Overlay
        ]);
    in {
      "cmyk" = {
        inherit extensions;
        id = 0;
        isDefault = true;
        name = "tonerlow";
        path = "notonercartridge";
        settings = import /home/toonn/src/nix-config/home/ff-userjs.nix;
        userChrome = builtins.readFile
          /home/toonn/src/dotfiles/ff-conf/chrome/userChrome.css;
        userContent = builtins.readFile
          /home/toonn/src/dotfiles/ff-conf/chrome/userContent.css;
      };
      "T8N" = {
        inherit extensions;
        id = 1;
        isDefault = false;
        name = "T8N";
        path = "T8N";
        settings = import /home/toonn/src/nix-config/home/ff-userjs.nix;
        userChrome = builtins.readFile
          /home/toonn/src/dotfiles/ff-conf/chrome/userChrome.css;
        userContent = builtins.readFile
          /home/toonn/src/dotfiles/ff-conf/chrome/userContent.css;
      };
      "WebGL" = {
        inherit extensions;
        id = 2;
        isDefault = false;
        name = "WebGL";
        path = "WebGL";
        settings = import /home/toonn/src/nix-config/home/ff-webgl-userjs.nix;
        userChrome = builtins.readFile
          /home/toonn/src/dotfiles/ff-conf/chrome/userChrome.css;
        userContent = builtins.readFile
          /home/toonn/src/dotfiles/ff-conf/chrome/userContent.css;
      };
      "Jitsi" = {
        inherit extensions;
        id = 3;
        isDefault = false;
        name = "Jitsi";
        path = "Jitsi";
        settings = import /home/toonn/src/nix-config/home/ff-webgl-userjs.nix;
        userChrome = builtins.readFile
          /home/toonn/src/dotfiles/ff-conf/chrome/userChrome.css;
        userContent = builtins.readFile
          /home/toonn/src/dotfiles/ff-conf/chrome/userContent.css;
      };
    };
  };

  programs.fish = { enable = true;
                    package = pkgs.fish;
                    shellInit = let fishUserPaths =
                        builtins.concatStringsSep " "
                        [ "$HOME/.nix-profile/bin"
                          "/run/current-system/sw/bin"
                          "/nix/var/nix/profiles/default/bin"
                        ];
                      in ''
                      # if set -l ind \
                      #      ( contains -i -- \
                      #          /nix/var/nix/profiles/per-user/root/channels \
                      #          $NIX_PATH \
                      #      )
                      #   set -e NIX_PATH[$ind]
                      # end

                      set fish_user_paths '${fishUserPaths}'
                    '';
                  };
  
  programs.git = { enable = true;
                   package = pkgs.git;
                   aliases =
                     { lg = "log --graph --pretty=format:'%C(auto)%h -%d %s"
                          + " %Cgreen(%cr) %C(bold blue)<%an>%Creset'";
                       st = "status -sb";
                       checkout-empty = "!checkout-empty() {"
                                       + " git checkout $("
                                         + "git commit-tree $("
                                          + "git hash-object -t tree /dev/null"
                                         + ") < /dev/null"
                                       +  ");"
                                      + " }; checkout-empty";
                       dirty = "!dirty() {"
                             + " for repo in"
                             + " $(fd -t d --maxdepth=2 '^\\.git$' -H \${@:-.}"
                             + " --exec echo '{//}');"
                             + " do"
                             + " state=$(git -C $repo -c status.color=always"
                             + " status -sb);"
                             + " if test $(printf \"$state\" | wc -l) -gt 1;"
                             + " then"
                             + " printf \"$repo: $state\\n\\n\";"
                             + " fi;"
                             + " done"
                             + " };"
                             + " dirty";
                       ignorefile = "!gi() {"
                                  + " curl -sL"
                                  + " https://www.toptal.com/developers"
                                    + "/gitignore/api/$@"
                                  + " ;};"
                                  + " gi";
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
                   signing = {
                     # No longer has a default value?
                     key = null; # Select key based on commit author
                     signByDefault = true;
                   };
                   userEmail = "toonn@toonn.io";
                   userName = "toonn";
                 };

  programs.info.enable = false;

  # Can't use this because I want my configuration in dotfiles.
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
                  title           = "\${?pause==no:Playing}\${?pause==yes:Paused} - \${working-directory} \${path}"; # for arbtt
                  script-opts-append = "autocrop-auto=no";
                };
       # profiles = { fast = { vo = "vdpau"; }; };
       scripts = with pkgs.mpvScripts; [ autocrop
                                         cycle-video-rotate
                                       ];
    };

  programs.ssh =
    { enable = true;
      extraConfig = "AddKeysToAgent yes"; # Add key to the agent on first use
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
                                   identityFile = [ "~/.ssh/terra_gh_id_ed25519"
                                                    "~/.ssh/yorp_gh_id_ed25519"
                                                  ];
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
                      "toxsol" = { hostname     = "10.0.0.5";
                                   user         = "toonn";
                                   identityFile = "~/.ssh/yorp_id_ed25519";
                                 };
                      "terra" = { hostname = "terra.local";
                                  user         = "toonn";
                                  identityFile = "~/.ssh/yorp_id_ed25519";
                                };
                      "titan" = { hostname = "titan.local";
                                  extraOptions = { preferredAuthentications =
                                                     "publickey,password";
                                                 };
                                };
                      "yorp" = { hostname     = "yorp.local";
                                 user         = "toonn";
                                 identityFile = "~/.ssh/yorp_id_ed25519";
                               };
                      "helium" = { hostname = "ssh.esat.kuleuven.be";
                                   user     = "r0258654";
                                 };
                      "lint" = { hostname     = "localhost";
                                 port         = 2222;
                                 user         = "r0258654";
                                 extraOptions = { hostKeyAlias = "lint"; };
                               };
                      # To avoid passing the path to the key file
                      "darwin-build-box" = {
                        hostname     = "darwin-build-box.winter.cafe";
                        user         = "toonn";
                        identityFile = "~/.ssh/darwin-build-box_id_ed25519";
                        extraOptions = { preferredAuthentications =
                                           "publickey";
                                       };
                      };
                      "community-build-box" = {
                        hostname     = "darwin-build-box.nix-community.org";
                        user         = "toonn";
                        identityFile = "~/.ssh/darwin-build-box_id_ed25519";
                        extraOptions = { preferredAuthentications =
                                           "publickey";
                                       };
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
                      set -g set-titles on
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

  programs.zathura = { enable = ! pkgs.stdenv.isDarwin; # Broken on darwin
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

  services.gpg-agent = { enable = true;
                         #enableSshSupport = true;
                         pinentryFlavor = "tty";
                         # for unstable: pinentryPackage = pkgs.pinentry-tty;
                         #sshKeys = [ "" ];
                       };

  # purple-matrix gets stuck on "Couldn't parse sync response" and crashes
  # bitlbee. Maybe leaving channels so the sync is smaller could help.
  services.pantalaimon = { enable = false;
                           package = with pkgs;
                           pantalaimon.overridePythonAttrs (oAs: {
                             propagatedBuildInputs = oAs.propagatedBuildInputs
                               ++ [ python3Packages.keyrings-cryptfile ];
                           });
                           settings = { matrix-org = {
                                          Homeserver = "https://matrix.org";
                                          ListenPort = 8448;
                                        };
                                      };
                         };


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

  systemd.user = {
    services = {
      "arbtt-capture" = {
        # enable = true;
        Service = {
          Environment = let path = builtins.concatStringsSep ":"
                                     ( map (p: "${lib.getBin p}/bin")
                                           ( with pkgs; [ haskellPackages.arbtt
                                                          coreutils
                                                        ]
                                           )
                                     );
                         in "PATH=${path}";
          ExecStart
            = let script
                    = pkgs.writeShellScript "arbtt-capture-start" ''
                        set -e
                        DATADIR="''${XDG_DATA_HOME:-$HOME/.local/share/arbtt}"
                        LOG="''${DATADIR}/''$(date +%Y).capture"
                        mkdir -p "''${DATADIR}"
                        arbtt-capture --logfile="''${LOG}"
                      '';
               in "${script}";
          Restart = "always";
        };
        Unit = {
          Description = "Arbtt capture service";
          PartOf = [ "graphical-session.target" ];
        };
        Install = {
          WantedBy = [ "graphical-session.target" ];
        };
      };
    };
    startServices = "sd-switch";
  };
}
