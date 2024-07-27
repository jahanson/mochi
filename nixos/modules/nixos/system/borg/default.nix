{ lib, config, ... }:
let
  cfg = config.mySystem.system.borgbackup;
in
{
  options.mySystem.system.borgbackup = {
    enable = lib.mkEnableOption "borgbackup";
    paths = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      required = true;
    };
    exclude = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      required = false;
    };
    repo = lib.mkOption {
      example = "borgbackup@myserver:repo";
      type = lib.types.str;
      default = "";
      required = true;
    };
    repoKeyPath = lib.mkOption {
      example = "/run/secrets/borgbackup/telchar";
      type = lib.types.str;
      default = "";
      required = false;
    };
  };

  config = lib.mkIf cfg.enable {
    services.borgbackup.jobs."borgbackup" = {
      paths = cfg.paths;
      exclude = cfg.exclude;
      repo = cfg.repo;
      encryption = {
        mode = "repokey-blake2";
        passCommand = "cat ${cfg.repoKeyPath}";
      };
      environment.BORG_RSH = "ssh -i /etc/ssh/ssh_host_ed25519_key";
    };
  };
}
