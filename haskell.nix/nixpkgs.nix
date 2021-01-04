let
  haskellNix = import (builtins.fetchTarball
    ( "https://github.com/input-output-hk/haskell.nix/archive/"
    + "dff53790cc515f03a9013f222d0faf9761546315.tar.gz"
    )) {};
in
  haskellNix.pkgs
