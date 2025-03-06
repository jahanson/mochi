{
  "durincore" = mkNixosConfig {
    # T470 Thinkpad Intel i7-6600U
    # Backup Nix dev laptop
    hostname = "durincore";
    system = "x86_64-linux";
    hardwareModules = [
      ./nixos/profiles/hw-thinkpad-t470.nix
      inputs.nixos-hardware.nixosModules.lenovo-thinkpad-t470s
    ];
    profileModules = [
      ./nixos/profiles/role-workstation.nix
      ./nixos/profiles/role-dev.nix
      {home-manager.users.jahanson = ./nixos/home/jahanson/workstation.nix;}
    ];
  };

  "legiondary" = mkNixosConfig {
    # Legion 15arh05h AMD/Nvidia Ryzen 7 4800H
    # Nix dev/gaming laptop
    hostname = "legiondary";
    system = "x86_64-linux";
    hardwareModules = [
      inputs.nixos-hardware.nixosModules.lenovo-legion-15arh05h
      ./nixos/profiles/hw-legion-15arh05h.nix
      disko.nixosModules.disko
      (import ./nixos/profiles/disko-nixos.nix {disks = ["/dev/nvme0n1"];})
    ];
    profileModules = [
      ./nixos/profiles/role-dev.nix
      ./nixos/profiles/role-gaming.nix
      ./nixos/profiles/role-workstation.nix
      {home-manager.users.jahanson = ./nixos/home/jahanson/workstation.nix;}
    ];
  };
}
