self: super: {

  clearurls = super.nur.repos.rycee.firefox-addons.buildFirefoxXpiAddon {
    pname = "clearurls";
    version = "1.17.0";
    addonId = "{74145f27-f039-47ce-a470-a662b129930a}";
    url = "https://addons.mozilla.org/firefox/downloads/file/3549538/clearurls-1.17.0-an+fx.xpi";
    sha256 = "1d6blk3jh2gnxsnxg70fc46dwsyzm7vvpyha18da6rdrhc1qrpka";
    meta = with super.lib; {
      homepage = "https://gitlab.com/KevinRoebert/ClearUrls";
      description = ''
        Automatically remove tracking elements from URLs to help protect your
        privacy when browsing the internet.
      '';
      license = licenses.lgpl3Plus;
      platforms = platforms.all;
    };
  };

  custom-title = super.nur.repos.rycee.firefox-addons.buildFirefoxXpiAddon
    ( let versions = super.lib.mapAttrs (v: as: as // { version = v; })
        { "1.0" = { sha256 = "1aa1rwdnyh46y34lqavhx6462748krimvy86ssd68w6szxnqy1wc";
                    urlNr = "3734747";
                  };
          "2.0" = { sha256 = "1ddr3csxx40skqralimsjjj1x4va2yq6mnr2cp89bc8f5mln4p1w";
                    urlNr = "3736903";
                  };
        };
        latest = versions."2.0";
      in {
        pname = "custom-title";
        version = latest.version;
        addonId = "{ebc29620-d4d6-4c18-822e-29ef46cd276d}";
        url = "https://addons.mozilla.org/firefox/downloads/file/${latest.urlNr}/custom_title-${latest.version}-fx.xpi";
        sha256 = latest.sha256;
        meta = with super.lib; {
          homepage = "https://github.com/toonn/CustomTitle";
          description = ''
            Webextension to add a tag to identify the current profile to the window
            title 
          '';
          license = licenses.bsd2;
          platforms = platforms.all;
        };
      }
    );

}
