{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.mySystem.de.kde;
  flameshotOverride = pkgs.unstable.flameshot.override {enableWlrSupport = true;};
in {
  options = {
    mySystem.de.kde = {
      enable =
        lib.mkEnableOption "KDE"
        // {
          default = false;
        };
    };
  };

  config = lib.mkIf cfg.enable {
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

    security = {
      # realtime process priority
      rtkit.enable = true;
      # KDE Wallet PAM integration for unlocking the default wallet on login
      pam.services."sddm".kwallet.enable = true;
    };

    # enable pipewire for sound
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;
    };

    # extra pkgs and extensions
    environment = {
      systemPackages = with pkgs; [
        wl-clipboard # ls ~/Downloads | wl-copy or wl-paste > clipboard.txt
        playerctl # gsconnect play/pause command
        vorta # Borg backup tool
        flameshotOverride # screenshot tool
        libsForQt5.qt5.qtbase # for vivaldi compatibility
        kdePackages.discover # KDE software center -- mainly for flatpak updates
      ];
    };

    # enable kdeconnect
    # this method also opens the firewall ports required when enable = true
    programs.kdeconnect = {
      enable = true;
    };
  };
}
