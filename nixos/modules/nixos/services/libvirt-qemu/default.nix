{
  lib,
  config,
  pkgs,
  inputs,
  ...
}:
with lib;
let
  cfg = config.mySystem.services.libvirt-qemu;
in
{
  imports = [ inputs.nixvirt-git.nixosModules.default ];
  options.mySystem.services.libvirt-qemu = {
    enable = mkEnableOption "libvirt-qemu";
  };

  config = mkIf cfg.enable {
    networking.firewall = {
      allowedTCPPorts = [
        16509
        16514
      ];
    };

    # Enable bind with domain configuration
    virtualisation.libvirt.enable = true;
    virtualisation.libvirtd = {
      enable = true;
      qemu = {
        package = pkgs.qemu_kvm;
        ovmf.enable = true;
        ovmf.packages = [ pkgs.OVMFFull.fd ];
      };
    };
  };
}
