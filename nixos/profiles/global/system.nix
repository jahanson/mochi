{ lib, pkgs, ... }:
{
  system = {
    # Enable printing changes on nix build etc with nvd
    activationScripts.report-changes = ''
      PATH=$PATH:${lib.makeBinPath [ pkgs.nvd pkgs.nix ]}
      nvd diff $(ls -dv /nix/var/nix/profiles/system-*-link | tail -2)
    '';

    # Do not change unless you know what you are doing
    stateVersion = "24.11";
  };
}
