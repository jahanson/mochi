{ lib, config, pkgs, ... }:
with lib;
let
  cfg = config.mySystem.de.kde;
in
{
  options = {
    mySystem.de.kde = {
      enable = mkEnableOption "KDE" // { default = false; };
    };
  };

  config = mkIf cfg.enable {
    # Ref: https://wiki.nixos.org/wiki/KDE

    # KDE
    services = {
      displayManager = {
        sddm = {
          enable = true;
          wayland = {
            enable = true;
          };
        };
      };
      desktopManager.plasma6.enable = true;
    };

    # extra pkgs and extensions
    environment = {
      systemPackages = with pkgs; [
        wl-clipboard # ls ~/Downloads | wl-copy or wl-paste > clipboard.txt
        playerctl # gsconnect play/pause command
      ];
    };

    # enable kdeconnect
    # this method also opens the firewall ports required when enable = true
    programs.kdeconnect = {
      enable = true;
    };
  };
}
