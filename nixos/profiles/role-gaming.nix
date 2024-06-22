{ pkgs, ... }:
{
  # Enable module for NVIDIA graphics
  mySystem = {
    hardware.nvidia.enable = true;
  };

  # set xserver videodrivers for NVIDIA gpu
  services.xserver.videoDrivers = [ "nvidia" ];
  # Install steam systemwide
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
  };

  # # Proton versions GUI and Wine
  environment.systemPackages = with pkgs; [
    protonup-qt
    wineWowPackages.waylandFull
    winetricks
  ];

  # sound.enable = lib.mkDefault true;
  # hardware.pulseaudio.enable = lib.mkForce false;
}
