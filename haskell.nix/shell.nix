{ pkgs ? import ./nixpkgs.nix
, haskellCompiler ? "ghc8107"
, hsPkgs
, for
, buildInputs ? []
}:
let
  haskell-nix = pkgs.haskell-nix;
  stackage = haskell-nix.snapshots."lts-16.20";
  hackage-package = haskell-nix.hackage-package;
in hsPkgs.shellFor {
  packages = ps: for;

  buildInputs =
    (map (p: stackage."${p}".components.exes."${p}")
    [ "brittany"
      "ghcid"
      "ormolu"
    ]
    ) ++ buildInputs;

  exactDeps = true;

  tools = let index-state = "2020-12-02T00:00:00Z";
    in { cabal = { version = "3.2.0.0"; inherit index-state; };
         fast-tags = { version = "2.0.0"; inherit index-state; };
       };

  withHoogle = true;
}
