{
  lib,
  config,
  pkgs,
  inputs,
  ...
}:
with lib; let
  cfg = config.myHome.de.hyprland;
in {
  options.myHome.de.hyprland.enable = mkEnableOption "Hyprland";

  imports = [inputs.ags.homeManagerModules.default];
  config = mkIf cfg.enable {
    programs.ags = {
      enable = true;

      # I don't want Home Manager to manage these config files.
      # Just setup the programs.
      configDir = null;

      extraPackages = with pkgs; [
        gtksourceview
        webkitgtk_6_0
        accountsservice
      ];
    };
  };
}
