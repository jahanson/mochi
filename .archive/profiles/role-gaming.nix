{
  lib,
  pkgs,
  ...
}: {
  # Enable module for NVIDIA graphics
  mySystem = {
    hardware.nvidia.enable = true;
  };

  # set xserver videodrivers for NVIDIA gpu
  services.xserver.videoDrivers = ["nvidia"];
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

  # Disable Alsa
  sound.enable = lib.mkDefault false;
  hardware.pulseaudio.enable = lib.mkForce false;

  # Realtime Kit
  security.rtkit.enable = true;
  # Enable pipewire
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };
}
