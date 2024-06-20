{ ... }:
{
  # Enable module for NVIDIA graphics
  mySystem.hardware.nvidia.enable = true;

  boot = {
    # for managing/mounting ntfs
    supportedFilesystems = [ "ntfs" ];

    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
      grub.memtest86.enable = true;
    };
  };

  # set xserver videodrivers for NVIDIA 4080 gpu
  services.xserver.videoDrivers = [ "nvidia" ];
}
