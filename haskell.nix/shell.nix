{ pkgs ? import ./nixpkgs.nix
, haskellCompiler ? "ghc912"
, hsPkgs
, for
, buildInputs ? []
, tools ? {}
}:
let
  inherit (pkgs.lib) mapAttrs;
  haskell-nix = pkgs.haskell-nix;
  # Pick the latest Stackage lts from before the index-state,
  # https://github.com/input-output-hk/stackage.nix/blob/master/ltss.nix
  stackage = haskell-nix.snapshots."lts-23.10";
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
                                  index-state = "2025-03-02T00:00:00Z";
                                }
                   )
                   { cabal = "3.14.1.1";
                     fast-tags = "2.0.3";
                     ghcid = "0.8.9";
                   }
       // tools;

   withHoogle = false; # true;  # Puny laptop has trouble building all the docs
}
