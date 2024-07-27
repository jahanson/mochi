{ lib, config, pkgs, ... }:
with lib;
let
  cfg = config.mySystem.services.bind;
  serviceUser = "named";
in
{
  options.mySystem.services.bind = {
    enable = mkEnableOption "bind";
    package = mkPackageOption pkgs "bind" { };
    extraConfig = mkOption {
      type = types.str;
    };
  };

  config = mkIf cfg.enable {
    networking.firewall = {
      allowedTCPPorts = [ 53 ];
      allowedUDPPorts = [ 53 ];
    };

    # Forces the machine to use the resolver provided by the network
    networking.resolvconf.useLocalResolver = mkForce false;

    # Enable bind with domain configuration
    services.bind = {
      enable = true;
      inherit (cfg) package;
      inherit (cfg) extraConfig;
    };

    # Clean up journal files
    systemd.services.bind = {
      preStart = mkAfter ''
        rm -rf ${config.services.bind.directory}/*.jnl
      '';
    };

    environment.persistence."${config.mySystem.system.impermanence.persistPath}" = mkIf config.mySystem.system.impermanence.enable {
      directories = [ services.bind.directory ];
    };
  };
}
