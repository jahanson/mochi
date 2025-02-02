{
  lib,
  config,
  pkgs,
  ...
}:
with lib; let
  cfg = config.myHome.programs.firefox;
in {
  options.myHome.programs.firefox.enable = mkEnableOption "Firefox";

  config = mkIf cfg.enable {
    programs.firefox = {
      enable = true;
      package = pkgs.firefox.override {
        extraPolicies = {
          DontCheckDefaultBrowser = true;
          DisablePocket = true;
        };
      };
      policies = import ./policies.nix;
      profiles.default = import ./profile-default.nix {inherit pkgs;};
    };
  };
}
