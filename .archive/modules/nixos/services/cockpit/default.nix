{
  lib,
  config,
  pkgs,
  ...
}:
with lib; let
  cfg = config.mySystem.services.cockpit;
in {
  options.mySystem.services.cockpit.enable = mkEnableOption "Cockpit";

  config.services.cockpit = mkIf cfg.enable {
    enable = true;
    openFirewall = true;
    package = pkgs.cockpit.overrideAttrs (old: {
      # remove packagekit and selinux, don't work on NixOS
      postBuild = ''
        ${old.postBuild}
        rm -rf \
          dist/packagekit \
          dist/selinux
      '';
    });
  };
}
