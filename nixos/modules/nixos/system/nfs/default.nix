{ lib
, config
, ...
}:
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
    system.nfs.server.enable = true;
    system.nfs.server.exports = cfg.exports;
    networking.firewall.allowedTCPPorts = [
      2049
    ];
  };
}
