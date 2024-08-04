{ lib, pkgs, ... }:
# Role for headless servers
with lib;
{
  config = {
    mySystem = {
      services.rebootRequiredCheck.enable = true;
      security.wheelNeedsSudoPassword = false;
      services.cockpit.enable = true;
      system.motd.enable = true;
    };

    nix.settings = {
      max-free = lib.mkDefault (1000 * 1000 * 1000);
      min-free = lib.mkDefault (128 * 1000 * 1000);
    };

    services = {
      logrotate.enable = mkDefault true;
      smartd.enable = mkDefault true;
    };

    environment = {
      systemPackages = [ pkgs.lazygit ];
    };

    documentation = {
      enable = mkDefault false;
      doc.enable = mkDefault false;
      info.enable = mkDefault false;
      man.enable = mkDefault false;
      nixos.enable = mkDefault false;
    };

    sound.enable = false;
    hardware.pulseaudio.enable = false;

    services.udisks2.enable = mkDefault false;
    programs.command-not-found.enable = mkDefault false;
  };
}
