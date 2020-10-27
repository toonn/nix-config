{ pkgs ? import ./nixpkgs.nix
, haskellCompiler ? "ghc8102"
, hsPkgs
, for
}:
let
  haskell-nix = pkgs.haskell-nix;
  stackage = haskell-nix.snapshots."lts-16.20";
  hackage-package = haskell-nix.hackage-package;
in hsPkgs.shellFor {
  packages = ps: for;

  buildInputs =
    (with pkgs; # Packages that don't work from hsPkgs for some reason
    [ cabal-install
    ]

    ) ++ (map (p: stackage."${p}".components.exes."${p}")
    [ "brittany"
      "ghcid"
      "ormolu"
    ]
    );

  exactDeps = true;

  tools = { fast-tags = "2.0.0"; };

  withHoogle = true;
}
