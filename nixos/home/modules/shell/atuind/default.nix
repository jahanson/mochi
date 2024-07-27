{ config, pkgs, lib, ... }:
with lib; let
  cfg = config.myHome.shell.atuind;
in
{
  options.myHome.shell.atuind = {
    enable = mkEnableOption "atuind";
  };

  config = mkMerge [
    (mkIf cfg.enable {
      systemd.user.services.atuind =
        {
          Install = {
            WantedBy = [ "default.target" ];
          };
          Unit = {
            After = [ "network.target" ];
          };
          Service = {
            Environment = "ATUIN_LOG=info";
            ExecStart = "${pkgs.unstable.atuin}/bin/atuin daemon";
            # Remove the socket file if the daemon is not running. 
            # Unexpected shutdowns may have left this file here.
            ExecStartPre="/run/current-system/sw/bin/bash -c '! pgrep atuin && /run/current-system/sw/bin/rm -f ~/.local/share/atuin/atuin.sock'";
          };
        };
    })
  ];
}
