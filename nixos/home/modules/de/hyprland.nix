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
    gtk = {
      enable = true;

      gtk3.extraConfig = {
        gtk-application-prefer-dark-theme = 1;
        gtk-theme-name = "Andromeda-dark";
        gtk-icon-theme-name = "Flat-Remix-Blue-Dark";
        gtk-font-name = "Fira Code Semi-Bold 14";
        gtk-cursor-theme-name = "Bibata-Modern-Ice";
        gtk-cursor-theme-size = 24;
        gtk-toolbar-style = "GTK_TOOLBAR_ICONS";
        gtk-toolbar-icon-size = "GTK_ICON_SIZE_LARGE_TOOLBAR";
        gtk-button-images = 1;
        gtk-menu-images = 1;
        gtk-enable-event-sounds = 1;
        gtk-enable-input-feedback-sounds = 0;
        gtk-xft-antialias = 1;
        gtk-xft-hinting = 1;
        gtk-xft-hintstyle = "hintslight";
        gtk-xft-rgba = "rgb";
      };
      gtk4.extraConfig = {
        gtk-application-prefer-dark-theme = "1";
      };
    };
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
