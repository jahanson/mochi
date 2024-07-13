{ lib, config, ... }:
let
  cfg = config.mySystem.services.samba;
in
{
  options.mySystem.services.samba = {
    enable = lib.mkEnableOption "samba";
    extraConfig = lib.mkOption {
      type = lib.types.str;
      default = "";
    };
    
    shares = lib.mkOption {
      type = lib.types.attrsOf (lib.types.attrsOf lib.types.unspecified);
      default = "";
    };
  };

  config = lib.mkIf cfg.enable {
    services.samba.enable = true;
    services.samba.extraConfig = cfg.extraConfig;
    services.samba.shares = cfg.shares;
    services.samba.openFirewall = true;
  };
}
