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
    jo
    jq
    nix
    unstable.ncdu
    yq

    # dev
    gh
    go
    nil
    nixpkgs-fmt
    shfmt
    statix
    tmux
    unstable.helix

    # flake imports
    inputs.nix-inspect.packages.${pkgs.system}.default
    inputs.talhelper.packages.${pkgs.system}.default

    # charmbracelet tools
    gum
    vhs
    mods
    soft-serve
  ];

  programs.direnv = {
    # TODO move to home-manager
    enable = true;
    nix-direnv.enable = true;
  };
}
