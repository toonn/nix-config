self: super: {
  bitlbee-facebook = super.bitlbee-facebook.overrideAttrs (oAs:
  # From usvi's branch and a commit on master but don't help with the crashes
    { patches = [
        ( super.fetchpatch {
           url = "https://github.com/bitlbee/bitlbee-facebook/commit/a31ccbe8331d57a49f77557b82304f02bb8d0105.patch";
           hash = "sha256-SIRscXxzyWd8DMwx3JNh7khFtEB85icg7iEM4OkmJBQ=";
          }
        )
        ( super.fetchpatch {
            url = "https://github.com/usvi/bitlbee-facebook/commit/31b56ec07d8b1682a15e1dde114810140dddcb4e.patch";
            hash = "sha256-U7Z9J+J/x90uF6IMOgpcCXBT9tB1x0ge4dXMLwQjocE=";
          }
        )
      ];
    }
  );
}
