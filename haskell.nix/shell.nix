{ pkgs ? import ./nixpkgs.nix
, haskellCompiler ? "ghc8107"
, hsPkgs
, for
, buildInputs ? []
}:
let
  haskell-nix = pkgs.haskell-nix;
  stackage = haskell-nix.snapshots."lts-18.18";
  hackage-package = haskell-nix.hackage-package;
in hsPkgs.shellFor {
  packages = ps: for;

  buildInputs =
    (map (p: stackage."${p}".components.exes."${p}")
    [ # "brittany"
      "ghcid"
      # "ormolu"
    ]
    ) ++ buildInputs;

  exactDeps = true;

  tools = let index-state = "2021-11-30T00:00:00Z";
    in { cabal = { version = "3.6.2.0"; inherit index-state; };
         fast-tags = { version = "2.0.1"; inherit index-state; };
       };

  withHoogle = true;
}
