{ lib, config, pkgs, ... }:
let
  cfg = config.mySystem.system.borg.pika-backup;
  user = "jahanson";
in
{
  options.mySystem.system.borg.pika-backup = {
    enable = lib.mkEnableOption "pika-backup";
  };

  config = lib.mkIf cfg.enable {
    # Add package
    environment.systemPackages = [
      pkgs.pika-backup
    ];
    # Setup auto start at login.
    home-manager.users.${user} = {
      home.file = {
        ".config/autostart/pika-backup.desktop".source = ./config/pika-backup.desktop;
      };
    };
  };
}
