{
  lib,
  config,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.mySystem.services.podman;
in
{
  options.mySystem.services.podman.enable = mkEnableOption "Podman";

  config = mkIf cfg.enable {
    virtualisation.podman = {
      enable = true;

      dockerCompat = true;
      extraPackages = [ pkgs.zfs ];

      # regular cleanup
      autoPrune.enable = true;
      autoPrune.dates = "weekly";

      # and add dns
      defaultNetwork.settings = {
        dns_enabled = false;
      };
    };
    virtualisation.oci-containers = {
      backend = "podman";
    };

    environment.systemPackages = with pkgs; [
      podman-tui # status of containers in the terminal
      podman-compose
      unstable.lazydocker
    ];

    programs.fish.shellAliases = {
      # lazydocker --> lazypodman
      lazypodman = "sudo DOCKER_HOST=unix:///run/podman/podman.sock lazydocker";
    };

    networking.firewall.interfaces.podman0.allowedUDPPorts = [ 53 ];

    # extra user for containers
    users.groups.kah = { };
    users.users = {
      kah = {
        uid = 568;
        group = "kah";
      };
      jahanson.extraGroups = [ "kah" ];
    };
  };
}
