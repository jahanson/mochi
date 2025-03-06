{
  lib,
  config,
  pkgs,
  ...
}:
with lib; let
  cfg = config.mySystem.services.sanoid;
in {
  options.mySystem.services.sanoid = {
    enable = mkEnableOption "sanoid";
    package = mkPackageOption pkgs "sanoid" {};
    datasets = mkOption {
      type = lib.types.attrsOf (lib.types.attrsOf lib.types.unspecified);
    };
    templates = mkOption {
      type = lib.types.attrsOf (lib.types.attrsOf lib.types.unspecified);
    };
  };

  config = mkIf cfg.enable {
    # Enable sanoid with the given templates and datasets
    services.sanoid = {
      enable = true;
      inherit (cfg) package datasets templates;
    };
  };
}
