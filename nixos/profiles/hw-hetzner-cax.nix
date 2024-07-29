{ lib, ... }: {
  imports = [ ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.initrd.availableKernelModules = [ "xhci_pci" "virtio_pci" "virtio_scsi" "usbhid" "sr_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];

  mySystem = {
    services.openssh.enable = true;
    security.wheelNeedsSudoPassword = false;

    # Restic backups disabled.
    # TODO: configure storagebox for hetzner backups
    system.resticBackup = {
      local.enable = false;
      local.noWarning = true;
      remote.enable = false;
      remote.noWarning = true;
    };
  };

  networking.useDHCP = lib.mkDefault true;
  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";
}
