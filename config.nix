{ pkgs }: {

packageOverrides = super: let self = super.pkgs; in with self; rec {
  myHaskellPackages = libProf: self: super:
    with pkgs.haskell.lib; let pkg = self.callPackage; in rec {

    coldasdice  = pkg ~/src/coldasdice {};
    marko-chain = pkg ~/src/marko-chain {};
    skeletonkey = pkg ~/src/skeletonkey {};

    mkDerivation = pkg: super.mkDerivation (pkg // {
      enableLibraryProfiling = libProf;
      enableExecutableProfiling = false;
    });
  };

  haskellPackages = haskell843Packages;

  haskell843Packages = super.haskell.packages.ghc843.override {
    overrides = self: super: (myHaskellPackages false self super)
      // (with pkgs.haskell.lib; {
          #ghc-exactprint = dontCheck super.ghc-exactprint;
          argon2 = dontCheck (super.argon2);
          #pointfree = doJailbreak super.pointfree;
          cryptohash-sha256 = dontCheck (super.cryptohash-sha256);
          #dhall = super.callHackage "dhall" "1.14.0" {};
          #ListLike = addBuildDepend super.ListLike super.semigroups;
          conduit-extra = dontCheck super.conduit-extra;
         });
  };
  haskell822Packages = super.haskell.packages.ghc822.override {
    overrides = self: super: (myHaskellPackages false self super)
      // (with pkgs.haskell.lib; {
          #ghc-exactprint = dontCheck super.ghc-exactprint;
          argon2 = dontCheck (super.argon2);
          pointfree = doJailbreak super.pointfree;
          cryptohash-sha256 = dontCheck (super.cryptohash-sha256);
          dhall = super.callHackage "dhall" "1.14.0" {};
          ListLike = addBuildDepend super.ListLike super.semigroups;
         });
  };
  profiledHaskellPackages = super.haskell.packages.ghc822.override {
    overrides = myHaskellPackages true;
  };

  ghc82Env = pkgs.myEnvFun {
    name = "ghc82";
    buildInputs = with haskellPackages; [
      (ghcWithHoogle (import ~/src/nix-config/package-list.nix))
      # dev tools
      apply-refact # hlint refactoring
      bind
      brittany
      cabal-install
      fast-tags
      # ghc-mod
      ghcid
      # hasktags
      hindent
      hlint
      pointfree
    ];
  };

  ghc82ProfEnv = pkgs.myEnvFun {
    name = "ghc82prof";
    buildInputs = with profiledHaskellPackages; [
      profiledHaskell821Packages.ghc
      # dev tools
      cabal-install
    ];
  };

  haskellToolsEnv = pkgs.buildEnv {
    name = "haskellTools";
    paths = [
      cabal-install
      cabal2nix
      stack
    ];
  };

  systemToolsEnv = pkgs.buildEnv {
    name = "systemTools";
    paths = [
      bind
      fd
      gist
      moreutils
      mupdf
      ripgrep
      rsync
      time
      tmux
      unrar
      unzip
      zip
    ];
  };

  linuxToolsEnv = pkgs.buildEnv {
    name = "linuxTools";
    paths = [
      dunst
      gnome3.file-roller
      tomb
      udisks2
      xdotool
    ];
  };

  netToolsEnv = pkgs.buildEnv {
    name = "netTools";
    paths = [
      irssi
      toxvpn
    ];
  };

  webToolsEnv = pkgs.buildEnv {
    name = "webTools";
    paths = [
      firefox
      #nylas-mail-bin
      thunderbird
    ];
  };

  gamesEnv = pkgs.buildEnv {
    name = "timeWastingTools";
    paths = [
      #desmume
      dwarf-fortress
      endless-sky
    ];
  };

  miscEnv = pkgs.buildEnv {
    name = "miscTools";
    paths = [
      anki
      inkscape
      ifuse
    ];
  };

  writingEnv = pkgs.myEnvFun {
    name = "writing";
    buildInputs = with haskellPackages; [
      pandoc
      rst2html5
      (texlive.combine { inherit (texlive)
                          scheme-small
                          collection-fontsrecommended
                          enumitem
                          fontawesome; })
      (ghcWithHoogle (import ~/src/nix-config/package-list.nix))
      # dev tools
      apply-refact # hlint refactoring
      cabal-install
      bind
      fast-tags
      ghcid
      hlint
      pointfree
    ];
  };
};

allowUnfree = true;
}
