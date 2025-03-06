{
  lib,
  config,
  pkgs,
  ...
}: {
  imports = [];

  boot = {
    loader = {
      efi.canTouchEfiVariables = true;
      systemd-boot.enable = true;
    };

    initrd = {
      kernelModules = ["nfs"];
      supportedFilesystems = ["nfs"];
      availableKernelModules = [
        "xhci_pci"
        "ahci"
        "nvme"
        "usbhid"
        "usb_storage"
        "sd_mod"
      ];
    };

    kernelModules = [
      "kvm-amd"
      "vfio"
      "vfio_iommu_type1"
      "vfio_pci"
      "vfio_virqfd"
    ];

    extraModulePackages = [];

    binfmt.emulatedSystems = ["aarch64-linux"]; # Enabled for arm compilation

    kernelParams = ["zfs.zfs_arc_max=107374182400"]; # 100GB
  };

  swapDevices = [];

  hardware = {
    cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
    nvidia = {
      modesetting.enable = true;
      nvidiaSettings = true;
      open = false;
      package = config.boot.kernelPackages.nvidiaPackages.latest;
      powerManagement = {
        enable = false;
        finegrained = false;
      };
    };
    graphics = {
      enable = true;
      enable32Bit = true;
      extraPackages = with pkgs; [
        vaapiVdpau
        libvdpau
        libvdpau-va-gl
        nvidia-vaapi-driver
        vdpauinfo
        libva
        libva-utils
      ];
    };
    # opengl.enable = true;
    nvidia-container-toolkit.enable = true;
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
        address = ["10.1.1.61/24"];
        routes = [
          {Gateway = "10.1.1.1";}
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
