{ config, lib, pkgs, imports, boot, self, inputs, ... }:
# Role for dev stations
# Could be a workstatio or a headless server.

with config;
{
  # git & vim are in global
  environment.systemPackages = with pkgs; [
    jq
    yq
    btop
    dnsutils
    nix

    # nix dev
    dnscontrol # for updating internal DNS servers with homelab services

    # TODO Move
    nil
    nixpkgs-fmt
    statix
    # nvd
    gh

    # bind # for dns utils like named-checkconf
    inputs.nix-inspect.packages.${pkgs.system}.default
  ];

  programs.direnv = {
    # TODO move to home-manager
    enable = true;
    nix-direnv.enable = true;
  };


}
