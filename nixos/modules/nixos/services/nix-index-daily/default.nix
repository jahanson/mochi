{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.mySystem.services.nix-index-daily;
in
{
  options.mySystem.services.nix-index-daily = {
    enable = lib.mkEnableOption "Automatic daily nix-index database updates";

    user = lib.mkOption {
      type = lib.types.str;
      description = "User account under which to run nix-index";
      example = "jahanson";
    };

    startTime = lib.mkOption {
      type = lib.types.str;
      default = "daily";
      description = "When to start the service. See systemd.time(7)";
      example = "05:00";
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.user = {
      # Timer for nix-index update
      timers.nix-index-update = {
        wantedBy = [ "timers.target" ];
        partOf = [ "nix-index-update.service" ];
        timerConfig = {
          OnCalendar = cfg.startTime;
          Persistent = true;
        };
      };
      # Service for nix-index update
      services.nix-index-update = {
        description = "Update nix-index database";
        script = "${pkgs.nix-index}/bin/nix-index";
        serviceConfig = {
          Type = "oneshot";
        };
      };
    };
  };
}
