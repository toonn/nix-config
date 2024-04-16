self: super: {
  xorg = super.xorg // {
    xf86inputlibinput = super.xorg.xf86inputlibinput.override {
      libinput = super.libinput.overrideAttrs (oAs: {
        version = oAs.version + "-patched";
        patches = oAs.patches ++ (
          let patchUntil = untilVersion: throwMessage: patch:
                if oAs.version >= untilVersion
                then throw throwMessage
                else super.fetchpatch patch;
              urlFromRev = rev:
                "https://gitlab.freedesktop.org/whot/libinput/-/commit/"
                + "${rev}.patch";
           in [ ( patchUntil "1.26" "Redundant scroll patch in libinput overlay"
                    { url
                        = urlFromRev "15609213a64461e5351ea13556a308a8eb65acc9";
                      hash
                        = "sha256-jtXg/PMJaQd2HGvqWnJPF4LcsQ8H0fVUkqXL6/CxXIE=";
                    }
                )
                ( patchUntil "1.26" "Redundant quirk patch in libinput overlay"
                    { url
                        = urlFromRev "570204cd36fe9ff6c4de9164c882597bd632adf6";
                      hash
                        = "sha256-v7rNNi5eN0KpOK9ca8lES1g8iTt9i6tjsX9N2JilBU0=";
                    }
                )
              ]
        );
      });
    };
  };
}
