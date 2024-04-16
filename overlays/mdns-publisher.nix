self: super: {
  mdns-publisher = super.callPackage (
    { lib, buildPythonPackage, fetchPypi
    , dbus-python
    }:

    buildPythonPackage rec {
      pname = "mdns-publisher";
      version = "0.9.2";

      src = fetchPypi {
        inherit pname version;
        sha256 = "1klgk6s2d3h2fbgfsv64p2f6lif3hd8ngbq04cvsqiq5gcm90c5j";
      };

      propagatedBuildInputs = [ dbus-python ];

      postPatch = ''
        # Emulated from https://github.com/NixOS/nixpkgs/blob/a0dbe47318bbab7559ffbfa7c4872a517833409f/pkgs/applications/terminal-emulators/terminator/default.nix#L50
        substituteInPlace setup.py --replace "\"dbus-python >= 1.1\"," ""
      '';

      doCheck = false;

      meta = with lib; {
        homepage = "https://github.com/carlosefr/mdns-publisher";
        description = "Publish CNAMEs pointing to the local host over Avahi/mDNS";
        longDescription = ''
          This service/library publishes CNAME records pointing to the local
          host over multicast DNS using the Avahi daemon found in all major
          Linux distributions. Useful as a poor-man's service discovery or as a
          helper for named virtual-hosts in development environments.

          Since Avahi is compatible with Apple's Bonjour, these names are
          usable from MacOS X and Windows too.
        '';
        license = licenses.mit;
        maintainers = with maintainers; [ toonn ];
      };
    }
  ) { inherit (super.python3Packages) buildPythonPackage fetchPypi dbus-python; };
}
