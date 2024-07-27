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
    };
    exclude = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
    };
    repo = lib.mkOption {
      example = "borgbackup@myserver:repo";
      type = lib.types.str;
      default = "";
    };
    repoKeyPath = lib.mkOption {
      example = "/run/secrets/borgbackup/telchar";
      type = lib.types.str;
      default = "";
    };
  };

  config = lib.mkIf cfg.enable {
    services.borgbackup.jobs."borgbackup" = {
      inherit (cfg) paths;
      inherit (cfg) exclude;
      inherit (cfg) repo;
      encryption = {
        mode = "repokey-blake2";
        passCommand = "cat ${cfg.repoKeyPath}";
      };
      environment.BORG_RSH = "ssh -i /etc/ssh/ssh_host_ed25519_key";
    };
  };
}
