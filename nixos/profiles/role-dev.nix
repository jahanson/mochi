{ config, pkgs, inputs, ... }:
# Role for dev stations
# Could be a workstatio or a headless server.

with config;
{
  # git & vim are in global
  environment.systemPackages = with pkgs; [
    btop
    dnsutils
    fira-code-nerdfont
    jq
    nix
    yq

    # TODO Move
    gh
    go
    nil
    nixpkgs-fmt
    shfmt
    statix

    # bind # for dns utils like named-checkconf
    inputs.nix-inspect.packages.${pkgs.system}.default
    inputs.talhelper.packages.${pkgs.system}.default
    inputs.ghostty.packages.${pkgs.system}.default
  ];

  programs.direnv = {
    # TODO move to home-manager
    enable = true;
    nix-direnv.enable = true;
  };
}
