{
  config,
  lib,
  pkgs,
  ...
}: {
  services.borgmatic = {
    enable = true;
    configurations.plex = {
      source_directories = [
        "/mnt/restic_nightly_backup/nahar/containers/volumes/plex/Library/"
      ];

      repositories = [
        {
          label = "local";
          path = "/eru/borg/plex";
        }
      ];

      storage.encryption_passcommand = ''${pkgs.coreutils-full}/bin/cat ${config.sops.secrets."borgmatic/encryption_passphrase".path}'';

      # Retention settings
      retention.keep_daily = 7;
      retention.keep_weekly = 4;
      retention.keep_monthly = 6;
      zfs = {
        zfs_command = "${pkgs.zfs}/bin/zfs";
        mount_command = "${pkgs.util-linux}/bin/mount";
        umount_command = "${pkgs.util-linux}/bin/umount";
      };
    };
  };
}
