{ config, pkgs, lib, ... }:
let
  cfg = config.mySystem.system.incus;
  user = "jahanson";
in
{
  # sops.secrets.secret-domain-0 = {
  #   sopsFile = ./secret.sops.yaml;
  # };
  options.mySystem.system.incus = {
    enable = lib.mkEnableOption "incus";
    preseed = lib.mkOption {
      type = lib.types.unspecified;
      default = "";
      description = "Incus preseed configuration. Generate with `incus admin init`.";
    };
    webuiport = lib.mkOption {
      type = lib.types.int;
      default = 8443;
      description = "Port for the Incus Web UI";
    };
  };

  config = lib.mkIf cfg.enable {

    virtualisation.incus = {
      inherit (cfg) preseed;
      enable = true;
      ui.enable = true;
    };

    users.users.${user}.extraGroups = [ "incus-admin" ];

    # systemd.services.incus-preseed.postStart = "${oidcSetup}";

    networking = {
      # nftables.enable = true;
      firewall = {
        allowedTCPPorts = [
          cfg.webuiport
          53
          67
        ];
        allowedUDPPorts = [
          53
          67
        ];
      };
    };
  };
}
