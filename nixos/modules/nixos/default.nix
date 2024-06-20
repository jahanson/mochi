{ lib, config, ... }:
with lib;
{
  imports = [
    ./system
    ./programs
    ./services
    ./de
    ./hardware
    ./containers
    ./lib.nix
    ./security
  ];

  options.mySystem.persistentFolder = mkOption {
    type = types.str;
    description = "persistent folder for nixos mutable files";
    default = "/persist";
  };

  options.mySystem.nasFolder = mkOption {
    type = types.str;
    description = "folder where nas mounts reside";
    default = "/mnt/nas";
  };

  options.mySystem.nasAddress = mkOption {
    type = types.str;
    description = "NAS Address or name for the backup nas";
    default = "10.1.1.13";
  };

  options.mySystem.domain = mkOption {
    type = types.str;
    description = "domain for hosted services";
    default = "";
  };

  options.mySystem.internalDomain = mkOption {
    type = types.str;
    description = "domain for local devices";
    default = "";
  };

  options.mySystem.purpose = mkOption {
    type = types.str;
    description = "System purpose";
    default = "Production";
  };

  options.mySystem.monitoring.prometheus.scrapeConfigs = mkOption {
    type = lib.types.listOf lib.types.attrs;
    description = "Prometheus scrape targets";
    default = [ ];
  };

  config = {
    systemd.tmpfiles.rules = [
      "d ${config.mySystem.persistentFolder} 777 - - -" #The - disables automatic cleanup, so the file wont be removed after a period
    ];
  };
}
