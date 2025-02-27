{
  lib,
  config,
  pkgs,
  inputs,
  ...
}: let
  cfg = config.mySystem.de.hyprland;
in {
  options = {
    mySystem.de.hyprland = {
      enable =
        lib.mkEnableOption "Hyprland"
        // {
          default = false;
        };
    };
  };
  config = lib.mkIf cfg.enable {
    # Hyprland nixpkgs system packages
    environment.systemPackages = with pkgs; [
      # Hyprland
      cava # Audio visualizer
      cliphist # Clipboard history
      duf # du tui - Disk Usage
      greetd.tuigreet # TUI login manager
      grim # Screenshot tool
      hypridle # Hyprland idle daemon
      inputs.ags.packages.${pkgs.stdenv.hostPlatform.system}.ags # AGS
      inxi # System information tool
      libva-utils # to view graphics capabilities
      loupe # Screenshot tool
      nvtopPackages.full # Video card monitoring
      nwg-displays # Display manager for Hyprland
      nwg-look # GTK settings editor, designed for Wayland.
      pyprland # Python bindings for Hyprland
      rofi-wayland # Window switcher and run dialog
      slurp # Select a region in Wayland
      swappy # Snapshot editor, designed for Wayland.
      swaynotificationcenter
      swww # Wallpaper daemon for wayland
      wallust # Generate and change colors schemes on the fly.
      wl-clipboard # Pipe to and from the clipboard
      wlogout
      wlr-randr # Wayland screen management
      wofi # Rofi for Wayland
      yad # Display dialog boxes from shell scripts
      (mpv.override {scripts = [mpvScripts.mpris];})
      # XDG things
      xdg-user-dirs
      xdg-utils
      # GTK things
      gnome-system-monitor
      bc
      baobab
      glib
      # Qt things
      gsettings-qt
      libsForQt5.qtstyleplugin-kvantum # Kvantum theme engine
      # bar
      libappindicator
      libnotify
    ];

    # Hyprland nixpkgs program modules
    programs = {
      # Hyprland DE
      hyprland = {
        enable = true;
        package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
        portalPackage =
          inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
        withUWSM = true;
      };
      ## Additional programs for the overall Hyprland experience
      waybar.enable = true;
      hyprlock.enable = true;
      nm-applet.indicator = true; # Compatability; Application indicator for NetworkManager
      thunar.enable = true;
      thunar.plugins = with pkgs.xfce; [
        exo
        mousepad
        thunar-archive-plugin
        thunar-volman
        tumbler
      ];
    };
    # Hyprland nixpkgs service modules
    services = {
      greetd = {
        enable = true;
        vt = 3;
        settings = {
          default_session = {
            user = "jahanson";
            command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --cmd='uwsm start select'"; # start Hyprland with a TUI login manager
          };
        };
      };
    };
    # Fonts
    fonts.packages = with pkgs; [
      fira-code
      font-awesome
      jetbrains-mono
      noto-fonts
      noto-fonts-cjk-sans
      terminus_font
      victor-mono
      unstable.nerd-fonts.jetbrains-mono
      unstable.nerd-fonts.fira-code
      unstable.nerd-fonts.fantasque-sans-mono
    ];
  };
}
