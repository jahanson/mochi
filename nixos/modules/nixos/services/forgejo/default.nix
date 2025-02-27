{
  lib,
  config,
  pkgs,
  ...
}:
with lib; let
  cfg = config.mySystem.services.forgejo;
  http_port = 3000;
  serviceUser = "forgejo";
  domain = "git.hsn.dev";
in {
  options.mySystem.services.forgejo = {
    enable = mkEnableOption "Forgejo";
    package = mkOption {
      type = types.package;
      default = pkgs.forgejo;
    };
  };

  config = mkIf cfg.enable {
    services.nginx = {
      virtualHosts.${domain} = {
        forceSSL = true;
        useACMEHost = config.networking.domain;
        extraConfig = ''
          client_max_body_size 512M;
        '';
        locations."/".proxyPass = "http://127.0.0.1:${toString http_port}";
      };
    };

    # Add path unit to check mount point before backup
    # We don't want to backup to the file system in case of network mount failure
    systemd.services."forgejo-dump-path-check" = {
      description = "Check if Forgejo backup mount point exists and is mounted";
      before = ["forgejo-dump.service"];
      requiredBy = ["forgejo-dump.service"];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${pkgs.util-linux}/bin/mountpoint /mnt/storagebox";
      };
    };

    services.forgejo = {
      enable = true;
      package = cfg.package;
      # enable forgejo db and data dumps daily
      dump = {
        enable = true;
        backupDir = "/mnt/storagebox/forgejo/backup";
        type = "tar.gz";
      };

      database.type = "postgres";
      # Enable support for Git Large File Storage
      lfs.enable = true;
      settings = {
        server = {
          DOMAIN = domain;
          # You need to specify this to remove the port from URLs in the web UI.
          ROOT_URL = "https://${domain}/";
          HTTP_PORT = http_port;
          # Default landing page on 'explore'
          LANDING_PAGE = "explore";
        };
        # You can temporarily allow registration to create an admin user.
        service = {
          DISABLE_REGISTRATION = true;
          ENABLE_NOTIFY_MAIL = true;
          REGISTER_EMAIL_CONFIRM = true;
          REQUIRE_SIGNIN_VIEW = false;
        };
        indexer = {
          REPO_INDEXER_ENABLED = true;
          REPO_INDEXER_PATH = "indexers/repos.bleve";
          MAX_FILE_SIZE = 1048576;
          REPO_INDEXER_INCLUDE = "";
          REPO_INDEXER_EXCLUDE = "resources/bin/**";
        };
        picture = {
          AVATAR_UPLOAD_PATH = "/var/lib/forgejo/data/avatars";
          REPOSITORY_AVATAR_UPLOAD_PATH = "/var/lib/forgejo/data/repo-avatars";
        };
        # Add support for actions, based on act: https://github.com/nektos/act
        actions = {
          ENABLED = true;
        };
        # Sending emails is completely optional
        # You can send a test email from the web UI at:
        # Profile Picture > Site Administration > Configuration >  Mailer Configuration
        mailer = {
          ENABLED = true;
          SMTP_ADDR = "smtp.mailgun.org";
          FROM = "git@hsn.dev";
          USER = "git@mg.hsn.dev";
          SMTP_PORT = 587;
        };
        session = {
          COOKIE_SECURE = true;
          COOKIE_NAME = "session";
        };
        "repository.signing" = {
          SIGNING_KEY = "default";
        };
      };

      secrets = {
        mailer.PASSWD = config.sops.secrets."services/forgejo/smtp/password".path;
      };
    };
    # sops
    sops.secrets."services/forgejo/smtp/password" = {
      sopsFile = ./secrets.sops.yaml;
      owner = serviceUser;
      mode = "400";
      restartUnits = ["forgejo.service"];
    };
  };
}
