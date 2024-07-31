{ lib, config, pkgs, ... }:
with lib;
let
  cfg = config.mySystem.de.gnome;
in
{
  options = {
    mySystem.de.gnome = {
      enable = mkEnableOption "GNOME" // { default = true; };
      systrayicons = mkEnableOption "Enable systray icons" // { default = true; };
      gsconnect = mkEnableOption "Enable gsconnect (KDEConnect for GNOME)" // { default = true; };
    };
  };

  config = mkIf cfg.enable {
    # Ref: https://nixos.wiki/wiki/GNOME

    # GNOME plz
    services = {
      displayManager = {
        defaultSession = "gnome";
        autoLogin = {
          enable = false;
          user = "jahanson"; # TODO move to config overlay
        };
      };

      xserver = {
        enable = true;
        xkb.layout = "us"; # `localctl` will give you

        displayManager = {
          gdm.enable = true;
        };
        desktopManager = {
          # GNOME
          gnome.enable = true;
        };
      };

      udev.packages = optionals cfg.systrayicons [ pkgs.gnome.gnome-settings-daemon ]; # support appindicator
    };

    # systyray icons
    # extra pkgs and extensions
    environment = {
      systemPackages = with pkgs; [
        wl-clipboard # ls ~/Downloads | wl-copy or wl-paste > clipboard.txt
        playerctl # gsconnect play/pause command
        pamixer # gcsconnect volume control
        gnome.gnome-tweaks
        gnome.dconf-editor

        # This installs the extension packages, but
        # dont forget to enable them per-user in dconf settings -> "org/gnome/shell"
        gnomeExtensions.vitals
        gnomeExtensions.caffeine
        gnomeExtensions.dash-to-dock
      ]
      ++ optionals cfg.systrayicons [ pkgs.gnomeExtensions.appindicator ];
    };

    # enable gsconnect
    # this method also opens the firewall ports required when enable = true
    programs.kdeconnect = mkIf
      cfg.gsconnect
      {
        enable = true;
        package = pkgs.gnomeExtensions.gsconnect;
      };

    # GNOME connection to browsers - requires flag on browser as well
    services.gnome.gnome-browser-connector.enable = lib.any
      (user: user.programs.firefox.enable)
      (lib.attrValues config.home-manager.users);

    # And dconf
    programs.dconf.enable = true;

    # Exclude default GNOME packages that dont interest me.
    environment.gnome.excludePackages =
      (with pkgs; [
        gnome-photos
        gnome-tour
        gedit # text editor
      ])
      ++ (with pkgs.gnome; [
        cheese # webcam tool
        gnome-music
        gnome-terminal
        epiphany # web browser
        geary # email reader
        evince # document viewer
        gnome-characters
        totem # video player
        tali # poker game
        iagno # go game
        hitori # sudoku game
        atomix # puzzle game
      ]);
  };


}
