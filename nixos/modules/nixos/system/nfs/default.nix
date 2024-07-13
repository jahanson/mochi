{ lib, config, ... }:
let
  cfg = config.mySystem.system.nfs;
in
{
  options.mySystem.system.nfs = {
    enable = lib.mkEnableOption "nfs";
    exports = lib.mkOption {
      type = lib.types.str;
      default = "";
    };
  };

  config = lib.mkIf cfg.enable {
    services.nfs.server.enable = true;
    services.nfs.server.exports = cfg.exports;
    networking.firewall.allowedTCPPorts = [
      2049
    ];
  };
}
