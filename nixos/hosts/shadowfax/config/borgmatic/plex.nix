{
  config,
  pkgs,
  ...
}: {
  mySystem.services.borgmatic = {
    configurations.plex = {
      source_directories = [
        "/nahar/containers/volumes/plex"
      ];

      repositories = [
        {
          label = "local";
          path = "/eru/borg/plex";
        }
        {
          label = "remote";
          path = "ssh://kvq39z04@kvq39z04.repo.borgbase.com/./repo";
        }
      ];

      ssh_command = "${pkgs.openssh}/bin/ssh -i ${config.sops.secrets."borgmatic/plex/append_key".path}";

      encryption_passcommand = ''${pkgs.coreutils-full}/bin/cat ${config.sops.secrets."borgmatic/plex/encryption_passphrase".path}'';

      # Retention settings
      keep_daily = 14;
      exclude_patterns = [
        "*/Cache/*"
      ];

      zfs = {
        zfs_command = "${pkgs.zfs}/bin/zfs";
        mount_command = "${pkgs.util-linux}/bin/mount";
        umount_command = "${pkgs.util-linux}/bin/umount";
      };
    };
  };
}
