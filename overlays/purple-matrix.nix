self: super:
let nur = import (builtins.fetchTarball
                   "https://github.com/nix-community/NUR/archive/main.tar.gz"
                 )
                 { inherit (super) pkgs;
                   repoOverrides = {
                     toonn = import /home/toonn/src/nur-packages {
                       inherit (super) pkgs;
                     };
                   };
                 };
in {
  purple-matrix = nur.repos.toonn.purple-matrix.overrideAttrs (oAs:
    { # version = "2022-07-04";
      # src = super.fetchFromGitHub {
      #   owner = "matrix-org";
      #   repo = "purple-matrix";
      #   rev = "91021c8";
      #   hash = "sha256-/asx/5rpe0RhEksZwAJUaQwwQfMMC8SMC5ZhmEjQARg=";
      # };
      version = "~/src/purple-matrix-WIP";
      src = /home/toonn/src/purple-matrix;
    }
  );
}
