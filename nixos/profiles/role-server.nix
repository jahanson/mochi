{ lib, pkgs, ... }:
# Role for headless servers
# covers raspi's, sbc, NUC etc, anything
# that is headless and minimal for running services
with lib;
{
  config = {
    # Enable monitoring for remote scraping
    mySystem = {
      services.rebootRequiredCheck.enable = true;
      security.wheelNeedsSudoPassword = false;
      services.cockpit.enable = true;
      system.motd.enable = true;
    };

    nix.settings = {
      # TODO factor out into mySystem
      # Avoid disk full issues
      max-free = lib.mkDefault (1000 * 1000 * 1000);
      min-free = lib.mkDefault (128 * 1000 * 1000);
    };

    services.logrotate.enable = mkDefault true;
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

    programs.command-not-found.enable = mkDefault false;
    sound.enable = mkDefault false;
    hardware.pulseaudio.enable = mkDefault false;
    services.udisks2.enable = mkDefault false;
  };
}
