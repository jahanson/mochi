{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.nix-index-daily;
in
{
  options.services.nix-index-daily = {
    enable = lib.mkEnableOption "Automatic daily nix-index database updates";

    user = lib.mkOption {
      type = lib.types.str;
      description = "User account under which to run nix-index";
      example = "alice";
    };

    startTime = lib.mkOption {
      type = lib.types.str;
      default = "daily";
      description = "When to start the service. See systemd.time(7)";
      example = "03:00";
    };

    randomizedDelaySec = lib.mkOption {
      type = lib.types.int;
      default = 3600;
      description = "Random delay in seconds after startTime";
      example = 1800;
    };
  };

  config = lib.mkIf cfg.enable {
    users.users.${cfg.user}.packages = [ pkgs.nix-index ];

    systemd.user.services.nix-index-update = {
      description = "Update nix-index database";
      script = "${pkgs.nix-index}/bin/nix-index";
      serviceConfig = {
        Type = "oneshot";
      };
    };

    systemd.user.timers.nix-index-update = {
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = cfg.startTime;
        Persistent = true;
        RandomizedDelaySec = cfg.randomizedDelaySec;
      };
    };

    # Ensure the services are enabled
    systemd.user.services.nix-index-update.enable = true;
    systemd.user.timers.nix-index-update.enable = true;
  };
}
