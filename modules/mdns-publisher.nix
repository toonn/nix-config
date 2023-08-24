{ config, lib, pkgs, ... }:

let cfg = config.services.mdns-publisher;
in with lib; {
  options.services.mdns-publisher = {
    names = mkOption {
      type = with types; listOf str;
      default = [];
      description = "List of names to publish as CNAMEs for localhost.";
    };
  };

  config = {
    services.avahi.publish.userServices = true;

    systemd.services.mdns-publish-cname = {
      after = [ "network.target" "avahi-daemon.service" ];
      description = "Avahi/mDNS CNAME publisher";
      enable = cfg.names != [];
      serviceConfig = {
        # Until https://github.com/systemd/systemd/issues/22737 gets fixed
        DynamicUser = false;
        Type = "simple";
        WorkingDirectory = "/var/empty";
        ExecStart = ''${pkgs.mdns-publisher}/bin/mdns-publish-cname --ttl 20 ${concatStringsSep " " cfg.names}'';
        Restart = "no";
        PrivateDevices = true;
      };
      wantedBy = [ "multi-user.target" ];
    };
  };
}
