let
  haskellNix = import (builtins.fetchTarball (
    "https://github.com/input-output-hk/haskell.nix/archive/"
    # + "e6a0d20e06aa16134446468c3f3f59ea92eb745b.tar.gz"
    # + "541d83fb498fb5d6582c481f16a7eb73c4b35fff.tar.gz"
    # + "70a0d1b5425171cb99a73e106978868d2bfda309.tar.gz"
    # + "3bbbb40cc0babb6d7f6b3b92d3ee25b934484cdc.tar.gz"
    # + "d68d84794999f7641b7c6500257e707f439bec36.tar.gz"
    # + "fadf9227afcdd93eedc656ba380f6a55d08fa650.tar.gz"
    # + "35dcaaa72029e4fbf0b5894ff979553dcbee6b8b.tar.gz"
    + "509c8926e157875d098ac0e919a5e5aaeb8c1e08.tar.gz"
  )) {};
in
  haskellNix.pkgs
