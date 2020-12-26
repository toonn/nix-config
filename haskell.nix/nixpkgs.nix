let
  haskellNix = import (builtins.fetchTarball
    ( "https://github.com/input-output-hk/haskell.nix/archive/"
    + "d014079ccee72d9fbd05e4f0af8c6481034283de.tar.gz"
    )) {};
in
  haskellNix.pkgs
