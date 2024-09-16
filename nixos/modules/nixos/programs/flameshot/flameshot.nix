{ config, lib, pkgs, ... }:
let
  cfg = config.mySystem.programs.flameshot;
in
{
  options.mySystem.programs.flameshot = {
    enable = lib.mkEnableOption "flameshot";
  };

  config = lib.mkIf cfg.enable {
    environment.sessionVariables = {
      XDG_SESSION_TYPE = "wayland";
      QT_QPA_PLATFORM = "wayland";
    };

    environment.systemPackages = with pkgs; [
      (unstable.flameshot.override { enableWlrSupport = true; })
      xdg-desktop-portal
      xdg-desktop-portal-gnome
    ];
  };
}
