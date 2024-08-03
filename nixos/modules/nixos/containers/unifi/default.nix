{ lib, config, ... }:
with lib;
let
  app = "unifi";
  # renovate: depName=github.com/goofball222/unifi datasource=github-releases
  version = "8.2.93";
  cfg = config.mySystem.services.${app};
  appFolder = "/eru/containers/volumes/${app}";
  # persistentFolder = "${config.mySystem.persistentFolder}/var/lib/${appFolder}";
in
{
  options.mySystem.services.${app} = {
    enable = mkEnableOption "${app}";
  };

  config = mkIf cfg.enable {
    networking.firewall.interfaces.podman0 = {
      allowedTCPPorts = [ 8080 8443 8880 8843 ];
      allowedUDPPorts = [ 3478 ];
    };
    virtualisation.oci-containers.containers.${app} = {
      image = "ghcr.io/goofball222/unifi:${version}";
      autoStart = true;
      ports = [
        "3478:3478/udp" # STUN
        "8080:8080" # inform controller
        "8443:8443" # https
        "8880:8880" # HTTP portal redirect
        "8843:8843" # HTTPS portal redirect
      ];
      environment = {
        TZ = "America/Chicago";
        RUNAS_UID0 = "false";
        PGID = "102";
        PUID = "999";
      };
      volumes = [
        "${appFolder}/cert:/usr/lib/unifi/cert"
        "${appFolder}/data:/usr/lib/unifi/data"
        "${appFolder}/logs:/usr/lib/unifi/logs"
      ];
    };
  };
}
