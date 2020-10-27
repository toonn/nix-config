let
  haskellNix = import (builtins.fetchTarball
    ( "https://github.com/input-output-hk/haskell.nix/archive/"
    + "2f48630357ea61c5a231273a9cdf9e71f9653c81.tar.gz"
    )) {};
in
  haskellNix.pkgs
