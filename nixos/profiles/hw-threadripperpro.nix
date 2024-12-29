{ lib, ... }:
{
  imports = [ ];

  boot = {
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
    initrd.availableKernelModules = [
      "xhci_pci"
      "ahci"
      "nvme"
      "usbhid"
      "usb_storage"
      "sd_mod"
    ];
    initrd.kernelModules = [ ];
    kernelModules = [ "kvm-amd" ];
    extraModulePackages = [ ];
  };

  mySystem = {
    services.openssh.enable = true;
    security.wheelNeedsSudoPassword = false;
  };

  systemd.network = {
    enable = true;
    # Create bond0 device
    netdevs = {
      "10-bond0" = {
        netdevConfig = {
          Kind = "bond";
          Name = "bond0";
        };
        bondConfig = {
          Mode = "802.3ad";
          TransmitHashPolicy = "layer3+4";
          LACPTransmitRate = "fast";
          MIIMonitorSec = "100ms";
        };
      };
    };
    # Attach nics to bond0
    networks = {
      "30-enp36s0f0" = {
        matchConfig.Name = "enp36s0f0";
        networkConfig.Bond = "bond0";
      };
      "30-enp36s0f1" = {
        matchConfig.Name = "enp36s0f1";
        networkConfig.Bond = "bond0";
      };
      "40-bond0" = {
        matchConfig.Name = "bond0";
        address = [ "10.1.1.61/24" ];
        routes = [
          { Gateway = "10.1.1.1"; }
        ];
        networkConfig = {
          LinkLocalAddressing = "no";
          DNS = "10.1.1.1";
          Domains = "hsn.internal";
        };
        linkConfig.RequiredForOnline = "routable";
      };
    };
  };

  networking = {
    useDHCP = lib.mkDefault false;
    nftables.enable = true;
  };
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
