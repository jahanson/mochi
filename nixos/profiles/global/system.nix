{ lib, pkgs, ... }:
{
  system = {
    # Enable printing changes on nix build etc with nvd
    activationScripts.report-changes = ''
      PATH=$PATH:${lib.makeBinPath [ pkgs.nvd pkgs.nix ]}
      profiles=$(${pkgs.coreutils}/bin/ls -dv /nix/var/nix/profiles/system-*-link | tail -2)
      profile_count=$(echo "$profiles" | ${pkgs.coreutils}/bin/wc -l)
      if [ $profile_count -gt 1 ]; then
        nvd diff $profiles
      else
        echo "Not enough system configurations to compare. Found only $profile_count profile."
      fi
    '';

    # Do not change unless you know what you are doing
    stateVersion = "24.05";
  };
}
