{ lib, ... }: {
  imports = [ ];

  boot = {
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
    initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usbhid" "usb_storage" "sd_mod" ];
    initrd.kernelModules = [ ];
    kernelModules = [ "kvm-amd" ];
    extraModulePackages = [ ];
  };

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
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  # not supported
  services.smartd.enable = false;
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
