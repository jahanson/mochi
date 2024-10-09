{ config, lib, pkgs, ... }:
let
  cfg = config.mySystem.games.steam;
in
{
  options.mySystem.games.steam = {
    enable = lib.mkEnableOption "Steam";
  };

  config = lib.mkIf cfg.enable {
    # Steam Games
    programs.steam = {
      enable = true;
      remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
      dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
    };

    # Need that glorious eggroll
    environment.systemPackages = with pkgs; [
      protonup-qt
    ];

  };
}
