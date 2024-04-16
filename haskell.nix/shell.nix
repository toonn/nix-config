{ pkgs ? import ./nixpkgs.nix
, haskellCompiler ? "ghc948"
, hsPkgs
, for
, buildInputs ? []
}:
let
  inherit (pkgs.lib) mapAttrs;
  haskell-nix = pkgs.haskell-nix;
  stackage = haskell-nix.snapshots."lts-21.22";
  hackage-package = haskell-nix.hackage-package;
in hsPkgs.shellFor {
  packages = ps: for;

  buildInputs =
    (map (p: stackage."${p}".components.exes."${p}")
    [ # "brittany"
      # "ormolu"
    ]
    ) ++ buildInputs;

  exactDeps = true;

  tools = mapAttrs (_: version: { inherit version;
                                  index-state = "2023-11-30T00:00:00Z";
                                }
                   )
                   { cabal = "3.10.2.1";
                     fast-tags = "2.0.2";
                     ghcid = "0.8.9";
                   };

   withHoogle = false; # true;  # Puny laptop has trouble building all the docs
}
