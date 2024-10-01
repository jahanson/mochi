{ pkgs, ... }:

let
  cleanupScript = pkgs.writeShellScriptBin "cleanup-backups.sh" (builtins.readFile ./prune-backups.sh);
in
{
  systemd.timers.cleanup-backups = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "daily";
      Persistent = true;
    };
  };

  systemd.services.cleanup-backups = {
    script = "${cleanupScript}/bin/cleanup-backups.sh";
    serviceConfig = {
      Type = "oneshot";
      User = "forgejo";
      StandardOutput = "journal+console";
      StandardError = "journal+console";
    };
  };
}
