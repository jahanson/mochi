{
  lib,
  config,
  pkgs,
  ...
}:
{

  # container builder
  lib.mySystem.mkContainer =
    options:
    (
      let
        containerExtraOptions =
          lib.optionals (lib.attrsets.attrByPath [ "caps" "privileged" ] false options) [ "--privileged" ]
          ++ lib.optionals (lib.attrsets.attrByPath [ "caps" "readOnly" ] false options) [ "--read-only" ]
          ++ lib.optionals (lib.attrsets.attrByPath [ "caps" "tmpfs" ] false options) (
            map (folders: "--tmpfs=${folders}") options.caps.tmpfsFolders
          )
          ++ lib.optionals (lib.attrsets.attrByPath [ "caps" "noNewPrivileges" ] false options) [
            "--security-opt=no-new-privileges"
          ]
          ++ lib.optionals (lib.attrsets.attrByPath [ "caps" "dropAll" ] false options) [ "--cap-drop=ALL" ];
      in
      {
        ${options.app} = {
          image = "${options.image}";
          user = "${options.user}:${options.group}";
          environment = {
            TZ = config.time.timeZone;
          } // lib.attrsets.attrByPath [ "env" ] { } options;
          dependsOn = lib.attrsets.attrByPath [ "dependsOn" ] [ ] options;
          entrypoint = lib.attrsets.attrByPath [ "entrypoint" ] null options;
          cmd = lib.attrsets.attrByPath [ "cmd" ] [ ] options;
          environmentFiles = lib.attrsets.attrByPath [ "envFiles" ] [ ] options;
          volumes = [
            "/etc/localtime:/etc/localtime:ro"
          ] ++ lib.attrsets.attrByPath [ "volumes" ] [ ] options;
          ports = lib.attrsets.attrByPath [ "ports" ] [ ] options;
          extraOptions = containerExtraOptions;
        };
      }
    );

  ## Creates a standardized restic backup configuration for both local and remote backups per app.
  # One S3 bucket per server. Each app has its own repository in the bucket.
  # Or backup each app it's own remote repository.
  # Takes an attribute set with:
  #   - app: name of the application (used for backup naming)
  #   - user: user to run the backup as
  #   - localResticTemplate: template for local restic backup
  #   - passwordFile: path to the password file
  #   - paths: list of paths to backup
  #   - remoteResticTemplate: template for remote restic backup
  #   - environmentFile (optional): path to the env file
  #   - excludePaths (optional): list of paths to exclude from backup
  # Configures:
  #   - Daily backups at 02:05 with 3h random delay
  #   - Retention: 7 daily, 5 weekly, 12 monthly backups
  #   - Automatic stale lock removal
  #   - Uses system-configured backup paths and credentials
  #
  # Example usage:
  #   services.restic.backups = config.lib.mySystem.mkRestic {
  #     app = "nextcloud";
  #     paths = [ "/nahar/containers/volumes/nextcloud" ];
  #     excludePaths = [ "/nahar/containers/volumes/nextcloud/data/cache" ];
  #     user = "kah";
  #     localResticTemplate = "/eru/restic/nextcloud";
  #     remoteResticTemplate = "rest:https://user:password@x.repo.borgbase.com";
  #     remoteResticTemplate = "s3:https://x.r2.cloudflarestorage.com/resticRepos";
  #     remoteResticTemplateFile = "/run/secrets/restic/nextcloud/template";
  #     passwordFile = "/run/secrets/restic/nextcloud/password";
  #     environmentFile = "/run/secrets/restic/nextcloud/env";
  #   };
  # This creates two backup jobs:
  #   - nextcloud-local: backs up to local storage
  #   - nextcloud-remote: backs up to remote storage (e.g. S3)
  lib.mySystem.mkRestic =
    options:
    let
      # excludePaths is optional
      excludePaths = if builtins.hasAttr "excludePaths" options then options.excludePaths else [ ];
      # Decide which mutually exclusive options to use
      remoteResticTemplateFile =
        if builtins.hasAttr "remoteResticTemplateFile" options then
          options.remoteResticTemplateFile
        else
          null;
      remoteResticTemplate =
        if builtins.hasAttr "remoteResticTemplate" options then options.remoteResticTemplate else null;
      # 2:05 daily backup with 3h random delay
      timerConfig = {
        OnCalendar = "06:05"; # night snap is taken at 02:10
        Persistent = true;
        RandomizedDelaySec = "30m";
      };
      # 7 daily, 5 weekly, 12 monthly backups
      pruneOpts = [
        "--keep-daily 7"
        "--keep-weekly 5"
      ];
      # Initialize the repository if it doesn't exist
      initialize = true;
      # Only one backup is ever running at a time it's safe to say that we can remove stale locks
      backupPrepareCommand = ''
        # remove stale locks - this avoids some occasional annoyance
        #
        ${pkgs.restic}/bin/restic unlock --remove-all || true
      '';
    in
    {
      # local backup
      "${options.app}-local" = {
        inherit
          pruneOpts
          timerConfig
          initialize
          backupPrepareCommand
          ;
        inherit (options) user passwordFile environmentFile;
        # Move the path to the zfs snapshot path
        paths = map (x: "${config.mySystem.services.zfs-nightly-snap.mountPath}/${x}") options.paths;
        exclude = map (
          x: "${config.mySystem.services.zfs-nightly-snap.mountPath}/${x}"
        ) options.excludePaths;
        repository = "${options.localResticTemplate}";
      };

      # remote backup
      "${options.app}-remote" = {
        inherit
          pruneOpts
          timerConfig
          initialize
          backupPrepareCommand
          ;
        inherit (options) user passwordFile environmentFile;
        # Move the path to the zfs snapshot path
        paths = map (x: "${config.mySystem.services.zfs-nightly-snap.mountPath}/${x}") options.paths;
        repository = remoteResticTemplate;
        repositoryFile = remoteResticTemplateFile;
        exclude = map (
          x: "${config.mySystem.services.zfs-nightly-snap.mountPath}/${x}"
        ) options.excludePaths;
      };
    };
}
