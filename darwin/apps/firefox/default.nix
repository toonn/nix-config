{ stdenv, fetchurl, undmg }:
stdenv.mkDerivation rec {
  name = "firefox-app-${version}";

  pname = "Firefox";

  version = "latest";

  # To update run:
  # nix-prefetch-url --name 'firefox-app-latest.dmg' 'https://download.mozilla.org/?product=firefox-latest&os=osx&lang=en-US'
  src = fetchurl {
    url =
      "https://download.mozilla.org/?product=firefox-latest&os=osx&lang=en-US";
    name = "${name}.dmg";
    sha256 = "1xycm3v8ix1lg91qv3kwihqbvq877crx88jn9vqaczvzl1zrdbic";
  };

  buildInputs = [ undmg ];

  # The dmg contains the app and a symlink, the default unpackPhase tries to cd
  # into the only directory produced so it fails.
  sourceRoot = ".";

  installPhase = ''
    mkdir -p $out/Applications
    mv ${pname}.app $out/Applications
    '';

  meta = with stdenv.lib; {
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
