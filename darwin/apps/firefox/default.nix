{ stdenv, lib, fetchurl, undmg }:
stdenv.mkDerivation rec {
  name = "firefox-app-${version}";

  pname = "Firefox";

  version = "latest";

  # To update run:
  # nix-prefetch-url --name 'firefox-app-latest.dmg' 'https://download.mozilla.org/?product=firefox-latest&os=osx&lang=en-US'
  src = let
    versions = {
      "86.0" = {
        sha256 = "04jslsfg073xb965hvbm7vdrdymkaiyyrgclv9qdpcyplis82rxc";
      };
      "86.0.1" = {
        sha256 = "1cd55z11wpkgi1lnidwg8kdxy8b6p00arz07sizrbyiiqxzrmvx3";
      };
      "87.0" = {
        sha256 = "1cih6i2p53mchqqrw2wlqhfka59p5qm4a7d0zc9ism0gvq5zpiz2";
      };
    };
    latest = versions."87.0";
  in fetchurl {
    inherit (latest) sha256;
    url =
      "https://download.mozilla.org/?product=firefox-latest&os=osx&lang=en-US";
    name = "${name}.dmg";
  };

  buildInputs = [ undmg ];

  # The dmg contains the app and a symlink, the default unpackPhase tries to cd
  # into the only directory produced so it fails.
  sourceRoot = ".";

  installPhase = ''
    mkdir -p $out/Applications
    mv ${pname}.app $out/Applications
    '';

  meta = with lib; {
    description = "Mozilla Firefox, free web browser (binary package)";
    homepage = "http://www.mozilla.org/firefox/";
    license = {
      free = false;
      url = "http://www.mozilla.org/en-US/foundation/trademarks/policy/";
    };
    maintainers = with maintainers; [ toonn ];
    platforms = [ "x86_64-darwin" ];
  };
}
