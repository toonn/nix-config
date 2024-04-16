self: super:
let addAttrnameToAttrs = super.lib.mapAttrs (v: as: as // { version = v; });
    latestVersion = defaultVersion: versions:
      versions."${
        super.lib.lists.foldr (v: lV:
          if builtins.compareVersions v lV == 1
          then v
          else lV
        )
        defaultVersion
        (builtins.attrNames versions)
      }";
    xpiURL = as: with as;
      "https://addons.mozilla.org/firefox/downloads/file/${urlNr}/${pname}-${version}.xpi";
in {

  belgium-eID = super.nur.repos.rycee.firefox-addons.buildFirefoxXpiAddon
    ( let versions = addAttrnameToAttrs
        { "1.0.32" = {
            sha256 = "sha256-t2zbE58IuHeAlM91lNX4rbiWLzt5sQq350b1PRdSY7w=";
            urlNr = "3736679";
          };
        };
        latest = latestVersion "1.0.32" versions;
      in rec {
        inherit (latest) sha256 version;
        pname = "belgium_eid";
        addonId = "belgiumeid@eid.belgium.be";
        url = xpiURL { inherit pname; inherit (latest) urlNr version; };
        meta = with super.lib; {
          homepage = "https://eid.belgium.be/en";
          description = ''
            Use the Belgian electronic identity card (eID) in Firefox
          '';
          license = licenses.gpl3;
          platforms = platforms.all;
        };
      }
    );

  clearurls = super.nur.repos.rycee.firefox-addons.buildFirefoxXpiAddon
    ( let versions = addAttrnameToAttrs
        { "1.17.0" = {
            sha256 = "1d6blk3jh2gnxsnxg70fc46dwsyzm7vvpyha18da6rdrhc1qrpka";
            urlNr = "3549538";
          };
          "1.26.1" = {
            sha256 = "sha256-4gFo1jyxuLo60N5M20LFQNmf4AqpZ5tZ9JvMw28QYpE=";
            urlNr = "4064884";
          };
        };
        latest = latestVersion "1.17.0" versions;
      in rec {
        inherit (latest) sha256 version;
        pname = "clearurls";
        addonId = "{74145f27-f039-47ce-a470-a662b129930a}";
        url = xpiURL { inherit pname; inherit (latest) urlNr version; };
        meta = with super.lib; {
          homepage = "https://gitlab.com/KevinRoebert/ClearUrls";
          description = ''
            Automatically remove tracking elements from URLs to help protect
            your privacy when browsing the internet.
          '';
          license = licenses.lgpl3Plus;
          platforms = platforms.all;
        };
      }
    );

  custom-title = super.nur.repos.rycee.firefox-addons.buildFirefoxXpiAddon
    ( let versions = addAttrnameToAttrs
        { "1.0" = {
            sha256 = "1aa1rwdnyh46y34lqavhx6462748krimvy86ssd68w6szxnqy1wc";
            urlNr = "3734747";
          };
          "2.0" = {
            sha256 = "1ddr3csxx40skqralimsjjj1x4va2yq6mnr2cp89bc8f5mln4p1w";
            urlNr = "3736903";
          };
        };
        latest = latestVersion "1.0" versions;
      in rec {
        inherit (latest) sha256 version;
        pname = "custom_title";
        addonId = "{ebc29620-d4d6-4c18-822e-29ef46cd276d}";
        url = xpiURL { inherit pname; inherit (latest) urlNr version; };
        meta = with super.lib; {
          homepage = "https://github.com/toonn/CustomTitle";
          description = ''
            Webextension to add a tag to identify the current profile to the
            window title
          '';
          license = licenses.bsd2;
          platforms = platforms.all;
        };
      }
    );

}
