{ config, pkgs, ... }:
{
  sops.secrets.secret-domain-0 = {
    sopsFile = ./secret.sops.yaml;
  };

  users.users.jahanson.extraGroups = [ "incus-admin" ];

  virtualisation.incus = {
    enable = true;
    ui.enable = true;
  };


  # systemd.services.incus-preseed.postStart = "${oidcSetup}";

  networking = {
    nftables.enable = true;
    firewall = {
      allowedTCPPorts = [
        8443
        53
        67
      ];
      allowedUDPPorts = [
        53
        67
      ];
    };
  };
}
