{ lib, config, ... }:
let
  cfg = config.mySystem.system.samba;
in
{
  options.mySystem.system.samba = {
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
    services = {
      samba = {
        enable = true;
        inherit (cfg) extraConfig shares;
        openFirewall = true;
      };
    };
  };
}
