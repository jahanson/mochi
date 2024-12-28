{
  lib,
  config,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.mySystem.services.haproxy;
  serviceUser = "named";
in
{
  options.mySystem.services.haproxy = {
    enable = mkEnableOption "haproxy" // {
      default = false;
    };
    package = mkPackageOption pkgs "haproxy" { };
    config = mkOption {
      type = types.str;
    };
    tcpPorts = mkOption {
      type = types.listOf types.int;
      default = [ ];
    };
    udpPorts = mkOption {
      type = types.listOf types.int;
      default = [ ];
    };
  };

  config = mkIf cfg.enable {
    # Open firewall for specified ports.
    networking.firewall = {
      allowedTCPPorts = cfg.tcpPorts;
      allowedUDPPorts = cfg.udpPorts;
    };

    # Enable haproxy service with custom configuration
    services.haproxy = {
      enable = true;
      inherit (cfg) package;
      inherit (cfg) config;
    };
  };
}
