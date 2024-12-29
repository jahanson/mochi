{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}:

with lib;
{
  # NOTE
  # Some 'global' areas have defaults set in their respective modules.
  # These will be applied when the modules are loaded
  # Not the global role.
  # Not sure at this point a good way to manage globals in one place
  # without mono-repo config.

  imports = [
    ./global
  ];
  config = {
    boot.tmp.cleanOnBoot = true;
    mySystem = {
      # basics for all devices
      editor.vim.enable = true;
      time.timeZone = "America/Chicago";
      security.increaseWheelLoginLimits = true;
      system.packages = [ pkgs.bat ];
      domain = "hsn.dev";
      shell.fish.enable = true;
    };

    environment.systemPackages = with pkgs; [
      curl
      wget
      dnsutils
      jq
      yq-go
      nvme-cli
      smartmontools
    ];

    networking.domain = config.mySystem.domain;
  };

}
