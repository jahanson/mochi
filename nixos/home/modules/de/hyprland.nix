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
    # Downloads the Theme Resources
    home.packages = with pkgs; [
      andromeda-gtk-theme
      flat-remix-icon-theme
      bibata-cursors
    ];
    # 'Installs' (sym-links) the Theme Resources
    home.file = {
      ".themes/Andromeda".source = "${pkgs.andromeda-gtk-theme}/share/themes/Andromeda";
      ".icons/Flat-Remix-Blue-Dark".source = "${pkgs.flat-remix-icon-theme}/share/icons/Flat-Remix-Blue-Dark";
      ".icons/Bibata-Modern-Ice".source = "${pkgs.bibata-cursors}/share/icons/Bibata-Modern-Ice";
    };
    # Theme settings
    gtk = {
      enable = true;
      # Some apps just need the good ol' ini files.
      gtk3.extraConfig = {
        gtk-application-prefer-dark-theme = 1;
        gtk-theme-name = "Andromeda";
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
        gtk-theme-name = "Andromeda";
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
    };
    # Wayland and apps pull from dconf since we're using the gtk portal.
    dconf.settings = {
      "org/gnome/desktop/interface" = {
        color-scheme = "prefer-dark";
        cursor-size = 24;
        cursor-theme = "Bibata-Modern-Ice";
        gtk-theme = "Andromeda";
        icon-theme = "Flat-Remix-Blue-Dark";
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
