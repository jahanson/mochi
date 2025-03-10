# Do not modify this file!  It was generated by `nixos-generate-config`
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{
  config,
  lib,
  modulesPath,
  pkgs,
  ...
}: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  networking.hostId = "ce196a02";
  networking.hostName = "telperion";
  boot = {
    initrd.availableKernelModules = [
      "xhci_pci"
      "ahci"
      "nvme"
      "usbhid"
      "usb_storage"
      "sd_mod"
    ];
    initrd.kernelModules = [];
    kernelModules = ["kvm-intel"];
    extraModulePackages = [];
  };
  fileSystems = {
    "/" = {
      device = "zroot/root";
      fsType = "zfs";
    };

    "/nix" = {
      device = "zroot/nix";
      fsType = "zfs";
    };

    "/var" = {
      device = "zroot/var";
      fsType = "zfs";
    };

    "/home" = {
      device = "zroot/home";
      fsType = "zfs";
    };
  };

  swapDevices = [];

  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  # Until I can figure out why the tftp port is not opening, disable the firewall.
  networking.firewall.enable = false;

  sops = {
    # Mounts unencrypted sops values at /run/secrets/rndc_keys accessible by root only by default.
    secrets = {
      "bind/rndc-keys/externaldns" = {
        owner = config.users.users.named.name;
        inherit (config.users.users.named) group;
        sopsFile = ./secrets.sops.yaml;
      };
      "bind/zones/jahanson.tech" = {
        owner = config.users.users.named.name;
        inherit (config.users.users.named) group;
        sopsFile = ./secrets.sops.yaml;
      };
      "1password-credentials.json" = {
        mode = "0444";
        sopsFile = ./secrets.sops.yaml;
      };
    };
  };
  networking.firewall.allowedTCPPorts = [
    80
    443
    2019
  ];
  services = {
    # Caddy
    caddy = {
      enable = true;
      package = pkgs.unstable.caddy;
      extraConfig = builtins.readFile ./config/Caddyfile;
      logFormat = lib.mkForce "level INFO";
    };

    # Tailscale
    tailscale = {
      enable = true;
      openFirewall = true;
      permitCertUid = builtins.toString config.users.users.caddy.uid;
    };
  };

  # System settings and services.
  mySystem = {
    purpose = "Production";
    system = {
      motd.networkInterfaces = [
        "enp2s0"
        "wlp3s0"
      ];
    };

    services = {
      podman.enable = true;

      onepassword-connect = {
        enable = true;
        credentialsFile = config.sops.secrets."1password-credentials.json".path;
      };

      bind = {
        enable = true;
        extraConfig = import ./config/bind.nix {inherit config;};
      };

      haproxy = {
        enable = true;
        config = import ./config/haproxy.nix {inherit config;};
        tcpPorts = [
          6443
          6444
          50000
        ];
      };

      matchbox = {
        enable = true;
        # /var/lib/matchbox/{profiles,groups,ignition,cloud,generic}
        dataPath = "/opt/talbox/data";
        # /var/lib/matchbox/assets
        assetPath = "/opt/talbox/assets";
      };

      dnsmasq = {
        enable = true;
        tftpRoot = "/opt/talbox";
        bootAsset = "http://10.1.1.57:8086/boot.ipxe";
      };
    };
  };
}
