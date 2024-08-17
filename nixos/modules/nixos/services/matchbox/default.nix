{ lib, config, pkgs, ... }:
with lib;
let
  cfg = config.mySystem.services.matchbox;
in
{
  options.mySystem.services.matchbox = {
    enable = mkEnableOption "matchbox";
    package = mkPackageOption pkgs "matchbox-server" { };
    dataPath = mkOption {
      type = types.str;
      example = "/var/lib/matchbox";
      description = "This is where profiles, groups, and other matchbox configuration is stored.";
    };
    assetPath = mkOption {
      type = types.str;
      example = "/var/lib/matchbox/assets";
      description = "This is where matchbox will look for assets like kernels and initrds.";
    };
  };

  config = mkIf cfg.enable {
    # Ensure the dataPath and assetPath directories exist
    systemd.tmpfiles.rules = [
      "d ${cfg.dataPath} 0755 matchbox matchbox"
      "d ${cfg.assetPath} 0755 matchbox matchbox"
    ];

    # Matchbox Server for PXE booting via device profiles
    environment.systemPackages = [
      cfg.package
    ];

    networking.firewall = {
      # HTTP communication
      allowedTCPPorts = [ 8086 ];
    };

    users.groups.matchbox = { };
    users.users = {
      matchbox = {
        home = cfg.dataPath;
        group = "matchbox";
        isSystemUser = true;
      };
    };

    systemd.services.matchbox = {
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];
      serviceConfig = {
        ExecStart = "${pkgs.matchbox-server}/bin/matchbox -address=0.0.0.0:8086 -data-path=${cfg.dataPath} -assets-path=${cfg.assetPath} -log-level=debug";
        Restart = "on-failure";
        User = "matchbox";
        Group = "matchbox";
      };
    };
  };
}
