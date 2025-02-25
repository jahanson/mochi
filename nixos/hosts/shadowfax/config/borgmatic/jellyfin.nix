{
  config,
  pkgs,
  ...
}: {
  mySystem.services.borgmatic = {
    configurations.jellyfin = {
      source_directories = [
        "/nahar/containers/volumes/jellyfin"
      ];

      repositories = [
        {
          label = "local";
          path = "/eru/borg/jellyfin";
        }
        {
          label = "remote";
          path = "ssh://uy5oy4m3@uy5oy4m3.repo.borgbase.com/./repo";
        }
      ];

      ssh_command = "${pkgs.openssh}/bin/ssh -i ${config.sops.secrets."borgmatic/jellyfin/append_key".path}";

      encryption_passcommand = ''${pkgs.coreutils-full}/bin/cat ${config.sops.secrets."borgmatic/jellyfin/encryption_passphrase".path}'';

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
