{ stdenv, lib, fetchurl
, unzip
}:
stdenv.mkDerivation rec {
  name = "openemu-${version}";

  version = "2.0.9.1";

  src = fetchurl {
    url =
    "https://github.com/OpenEmu/OpenEmu/releases/download/v${version}/OpenEmu_${version}.zip";
    name = name;
    sha256 = "141phya7nivywfmdvcm1c1zkm2cf850yjbz13gpfz32f21s660y6";
  };

  buildInputs = [ unzip ];

  unpackPhase = ''
    unzip "$src"
  '';

  installPhase = ''
    mkdir -p $out/Applications
    mv OpenEmu.app $out/Applications
  '';

  meta = with lib; {
    description = "Retro video game emulation for macOS";
    longDescription = ''
      OpenEmu is an open source project whose purpose is to bring macOS game
      emulation into the realm of first class citizenship. The project
      leverages modern macOS technologies, such as Cocoa, Core Animation with
      Quartz Composer, and other third-party libraries. One third-party library
      example is Sparkle, which is used for auto-updating. OpenEmu uses a
      modular architecture, allowing for game-engine plugins, allowing OpenEmu
      to support a host of different emulation engines and back ends while
      retaining the familiar macOS native front end.

      Currently OpenEmu can load the following game engines as plugins:

        - Atari 2600 (Stella)
        - Atari 5200 (Atari800)
        - Atari 7800 (ProSystem)
        - Atari Lynx (Mednafen)
        - ColecoVision (CrabEmu)
        - Famicom Disk System (Nestopia)
        - Game Boy / Game Boy Color (Gambatte)
        - Game Boy Advance (mGBA)
        - Game Gear (Genesis Plus)
        - Intellivision (Bliss)
        - NeoGeo Pocket (Mednafen)
        - Nintendo (NES) / Famicom (FCEUX, Nestopia)
        - Nintendo 64 (Mupen64Plus)
        - Nintendo DS (DeSmuME)
        - Odyssey² / Videopac+ (O2EM)
        - PC-FX (Mednafen)
        - SG-1000 (Genesis Plus)
        - Sega 32X (picodrive)
        - Sega CD / Mega CD (Genesis Plus)
        - Sega Genesis / Mega Drive (Genesis Plus)
        - Sega Master System (Genesis Plus)
        - Sega Saturn (Mednafen)
        - Sony PSP (PPSSPP)
        - Sony PlayStation (Mednafen)
        - Super Nintendo (SNES) (Higan, Snes9x)
        - TurboGrafx-16 / PC Engine (Mednafen)
        - TurboGrafx-CD / PCE-CD (Mednafen)
        - Vectrex (VecXGL)
        - Virtual Boy (Mednafen)
        - WonderSwan (Mednafen)
    '';
    homepage = "https://openemu.org/";
    license = licenses.unfree;
    maintainers = with maintainers; [ toonn ];
    platforms = [ "x86_64-darwin" ];
  };
}
