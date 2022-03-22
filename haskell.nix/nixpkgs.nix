let
  haskellNix = import (builtins.fetchTarball
    ( "https://github.com/input-output-hk/haskell.nix/archive/"
    + "70a0d1b5425171cb99a73e106978868d2bfda309.tar.gz"
    )) {};
in
  haskellNix.pkgs
