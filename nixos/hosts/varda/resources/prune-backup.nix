{ pkgs, ... }:

let
  cleanupScript = pkgs.writeScript "cleanup-backups.sh" (builtins.readFile ./prune-backups.sh);
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
    script = "${cleanupScript}";
    serviceConfig = {
      Type = "oneshot";
      User = "forgejo";
      StandardOutput = "journal+console";
      StandardError = "journal+console";
    };
  };
}
