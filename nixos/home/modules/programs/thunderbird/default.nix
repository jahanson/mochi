{ config, pkgs, lib, ... }:
let
  cfg = config.myHome.programs.thunderbird;

  policies = {
    ExtensionSettings = {
      "*".installation_mode = "blocked"; # blocks all addons except the ones specified below
      "quickmove@mozilla.kewis.ch" = {
        # Quick folder move
        # https://addons.thunderbird.net/en-US/thunderbird/addon/quick-folder-move/
        install_url = "https://addons.thunderbird.net/thunderbird/downloads/latest/quick-folder-move/latest.xpi";
        installation_mode = "force_installed";
      };
      # https://addons.thunderbird.net/user-media/addons/_attachments/987716/minimize_on_close-2.0.1.4-tb.xpi
      "minimizeonclose@rsjtdrjgfuzkfg.com" = {
        # Minimize on Close
        # https://addons.thunderbird.net/en-US/thunderbird/addon/minimize-on-close/
        install_url = "https://addons.thunderbird.net/user-media/addons/_attachments/987716/minimize_on_close-2.0.1.4-tb.xpi";
        installation_mode = "force_installed";
      };
    };
  };
in
{
  options.myHome.programs.thunderbird.enable = lib.mkEnableOption "Thunderbird";

  config = lib.mkIf cfg.enable {
    programs.thunderbird = {
      enable = true;
      package = pkgs.thunderbird-128.override (old: {
        extraPolicies = (old.extrapPolicies or { }) // policies;
      });

      profiles.default.isDefault = true;
    };
  };
}
