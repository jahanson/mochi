{ pkgs, config, lib, ... }:
let
  cfg = config.mySystem.services.glances;
in
with lib;
{
  options.mySystem.services.glances =
    {
      enable = mkEnableOption "Glances system monitor";
    };
  config = mkIf cfg.enable {

    environment.systemPackages = with pkgs;
      [ glances python310Packages.psutil hddtemp ];

    # port 61208
    systemd.services.glances = {
      script = ''
        ${pkgs.glances}/bin/glances --enable-plugin smart --webserver --bind 0.0.0.0
      '';
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
    };

    networking = {
      firewall.allowedTCPPorts = [ 61208 ];
    };

    environment.etc."glances/glances.conf" = {
      text = ''
        [global]
        check_update=False

        [network]
        hide=lo,docker.*

        [diskio]
        hide=loop.*

        [containers]
        disable=False
        podman_sock=unix:///var/run/podman/podman.sock

        [connections]
        disable=True

        [irq]
        disable=True
      '';
    };
  };
}
