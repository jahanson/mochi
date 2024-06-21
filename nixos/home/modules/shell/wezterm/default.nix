{ config, pkgs, lib, ... }:
with lib; let
  cfg = config.myHome.shell.wezterm;
in
{
  options.myHome.shell.wezterm = {
    enable = mkEnableOption "wezterm";
    configPath = mkOption {
      type = types.str;
    };
  };

  config = mkIf cfg.enable {
    # xdg.configFile."wezterm/wezterm.lua".source = config.lib.file.mkOutOfStoreSymlink cfg.configPath;
    programs.wezterm.package = pkgs.wezterm;
    programs.wezterm = {
      enable = true;
      extraConfig = ''
        local wez = require('wezterm')
        local xcursor_size = nil
        local xcursor_theme = nil

        local success, stdout, stderr = wezterm.run_child_process({"gsettings", "get", "org.gnome.desktop.interface", "cursor-theme"})
        if success then
          xcursor_theme = stdout:gsub("'(.+)'\n", "%1")
        end

        local success, stdout, stderr = wezterm.run_child_process({"gsettings", "get", "org.gnome.desktop.interface", "cursor-size"})
        if success then
          xcursor_size = tonumber(stdout)
        end

        return {
          -- issue relating to nvidia drivers
          -- https://github.com/wez/wezterm/issues/2011
          -- had to build out 550.67 manually to 'fix'
          enable_wayland = true,

          xcursor_theme = xcursor_theme,
          xcursor_size = xcursor_size,

          color_scheme   = "Dracula (Official)",
          check_for_updates = false,
          window_background_opacity = .90,
          window_padding = {
            left = '2cell',
            right = '2cell',
            top = '1cell',
            bottom = '0cell',
          },
        }
      '';
    };
  };
}
