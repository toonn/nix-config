self: super: {
  neomutt = let p =
    ( super.callPackage
        ( super.fetchurl
           { url = "https://raw.githubusercontent.com/NixOS/nixpkgs/1d0432ec589c12815b84e2c944c38b800e541145/pkgs/applications/networking/mailreaders/neomutt/default.nix";
             hash = "sha256-LcbtMc0WHlKUBXXolhk/3s95pDFbd//whWSLk/bbnAw=";
           }
        )
        {}
    ).overrideAttrs ( oAs:
      { patches = super.fetchpatch
          { url = "https://raw.githubusercontent.com/NixOS/nixpkgs/1d0432ec589c12815b84e2c944c38b800e541145/pkgs/applications/networking/mailreaders/neomutt/fix-open-very-large-mailbox.patch";
            hash = "sha256-xpehzA4cGD8DjZqx8x5ACAX0Xy4yreF816J7G4Zsyks=";
          };
      }
    );
    in if p.version <= super.neomutt.version
       then throw "NeoMutt overlay no longer necessary!"
       else p;
}
