# Adjusted manually from generated output of dconf2nix
# https://github.com/gvolpe/dconf2nix
{
  lib,
  pkgs,
  osConfig,
  ...
}:
with lib.hm.gvariant; {
  config = lib.mkIf osConfig.mySystem.de.gnome.enable {
    # add user packages
    home.packages = with pkgs; [
      dconf2nix
    ];

    # worked out from dconf2nix
    # `dconf dump / | dconf2nix > dconf.nix`
    # can also dconf watch
    dconf.settings = {
      "org/gnome/mutter" = {
        edge-tiling = true;
        workspaces-only-on-primary = false;
      };
      "org/gnome/settings-daemon/plugins/media-keys" = {
        home = ["<Super>e"];
      };
      "org/gnome/desktop/wm/preferences" = {
        workspace-names = [
          "sys"
          "talk"
          "web"
          "edit"
          "run"
        ];
        button-layout = "appmenu:minimize,close";
      };
      "org/gnome/shell" = {
        disabled-extensions = [
          "apps-menu@gnome-shell-extensions.gcampax.github.com"
          "light-style@gnome-shell-extensions.gcampax.github.com"
          "places-menu@gnome-shell-extensions.gcampax.github.com"
          "drive-menu@gnome-shell-extensions.gcampax.github.com"
          "window-list@gnome-shell-extensions.gcampax.github.com"
          "workspace-indicator@gnome-shell-extensions.gcampax.github.com"
        ];
        enabled-extensions = [
          "appindicatorsupport@rgcjonas.gmail.com"
          "caffeine@patapon.info"
          "dash-to-dock@micxgx.gmail.com"
          "gsconnect@andyholmes.github.io"
          "Vitals@CoreCoding.com"
          "sp-tray@sp-tray.esenliyim.github.com"
        ];
        favorite-apps = [
          "com.mitchellh.ghostty.desktop"
          "vivaldi-stable.desktop"
          "obsidian.desktop"
          "code.desktop"
          "vesktop.desktop"
        ];
      };
      "org/gnome/nautilus/preferences" = {
        default-folder-viewer = "list-view";
      };
      "org/gnome/nautilus/icon-view" = {
        default-zoom-level = "small";
      };
      "org/gnome/desktop/interface" = {
        color-scheme = "prefer-dark";
      };
      "org/gnome/desktop/peripherals/touchpad" = {
        tap-to-click = false;
      };
      "org/gnome/desktop/interface" = {
        clock-format = "12h";
        show-battery-percentage = true;
      };
      "org/gnome/settings-daemon/plugins/power" = {
        ambient-enabled = false;
      };
    };
  };
}
