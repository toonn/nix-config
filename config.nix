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

  haskellPackages = haskell822Packages;

  haskell822Packages = super.haskell.packages.ghc822.override {
    overrides = self: super: (myHaskellPackages false self super)
      // (with pkgs.haskell.lib; {
          #ghc-exactprint = dontCheck super.ghc-exactprint;
          argon2 = dontCheck (doJailbreak super.argon2);
          pointfree = doJailbreak super.pointfree;
          cryptohash-sha256 = dontCheck (super.cryptohash-sha256);
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
      cabal-install
      bind
      fast-tags
      #ghc-mod
      ghcid
      # hasktags
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
      gnome3.file-roller
      gist
      moreutils
      mupdf
      ripgrep
      rsync
      time
      tmux
      tomb
      udisks2
      unrar
      unzip
      xdotool
      zip
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
    buildInputs = [
      pandoc
      rst2html5
      (texlive.combine { inherit (texlive)
                          scheme-small
                          collection-fontsrecommended
                          enumitem; })
    ];
  };
};

allowUnfree = true;
}
