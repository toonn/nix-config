self: super: {
  mpvScripts.autocrop = super.callPackage
    ({ stdenv, fetchurl, mpv-unwrapped, lib }: 
      stdenv.mkDerivation rec {
        pname = "mpv-autocrop";
        version = mpv-unwrapped.version;
        src = "${mpv-unwrapped.src.outPath}/TOOLS/lua/autocrop.lua";
        dontBuild = true;
        dontUnpack = true;
        installPhase = ''
          install -Dm644 ${src} $out/share/mpv/scripts/autocrop.lua
        '';
        passthru.scriptName = "autocrop.lua";

        meta = {
          description = "This script uses the lavfi cropdetect filter to"
                      + " automatically insert a crop filter with appropriate"
                      + " parameters for the currently playing video.";
          homepage = "https://github.com/mpv-player/mpv/blob/master/TOOLS/lua/"
                   + "autocrop.lua";
          maintainers = [ lib.maintainers.toonn ];
          license = lib.licenses.gpl2Plus;
        };
      }) {};

  mpvScripts.cycle-video-rotate = super.callPackage
    ({ stdenv, fetchurl, mpv-unwrapped, lib }: 
      stdenv.mkDerivation rec {
        pname = "mpv-cycle-video-rotate";
        version = mpv-unwrapped.version;
        src = fetchurl {
          url =
            "https://raw.githubusercontent.com/VideoPlayerCode/mpv-tools/master/scripts/cycle-video-rotate.lua";
          sha256 = "0vj53knl08wjrvlmlnkjy5qk7rrlsd0sg9548i020wc4nscz8bk7";
        };
        dontBuild = true;
        dontUnpack = true;
        installPhase = ''
          install -Dm644 ${src} $out/share/mpv/scripts/cycle-video-rotate.lua
        '';
        passthru.scriptName = "cycle-video-rotate.lua";

        meta = {
          description = "Allows you to perform video rotation which perfectly"
                      + " cycles through all 360 degrees without any glitches.";
          homepage = "https://github.com/SteveJobzniak/mpv-tools";
          maintainers = [ lib.maintainers.toonn ];
          license = lib.licenses.gpl2Plus;
        };
      }) {};
}
