{ ... }:
{
  # Enable module for NVIDIA graphics
  mySystem.hardware.nvidia.enable = true;

  # set xserver videodrivers for NVIDIA gpu
  services.xserver.videoDrivers = [ "nvidia" ];
}
