{ stdenv, fetchurl, lib, undmg }:
stdenv.mkDerivation rec {
  name = "kicad-app-${version}";

  pname = "KiCad";

  version = "5.1.6"; # Latest version supported on 10.13

  src = fetchurl {
    url =
      "https://kicad-downloads.s3.cern.ch/osx/stable/kicad-unified-${version}-0.dmg";
    name = "${name}.dmg";
    sha256 = "02fq4byrg1sdvk4dcjxxagdri4n9vl55p7mqdschjxc71vqawayb";
  };

  buildInputs = [ undmg ];

  # The dmg contains directories and symlinks, the default unpackPhase tries to
  # cd into the only directory produced so it fails.
  sourceRoot = ".";

  # The dmg contains two directories that collide on a case-insensitive file
  # system. To separate them again we first extract all the apps and then move
  # everything else.
  installPhase = ''
    mkdir -p $out/Applications/KiCad
    mv KiCad/*.app $out/Applications/KiCad
    mkdir -p $out/'Application Support'/kicad
    mv KiCad/* $out/'Application Support'/kicad
    '';

  meta = with stdenv.lib; {
    description = "Open Source Electronics Design Automation suite";
    homepage = "https://www.kicad-pcb.org/";
    longDescription = ''
      KiCad is an open source software suite for Electronic Design Automation.
      The Programs handle Schematic Capture, and PCB Layout with Gerber output.
    '';
    license = lib.licenses.agpl3;
    maintainers = with maintainers; [ toonn ];
    platforms = [ "x86_64-darwin" ];
  };
}
