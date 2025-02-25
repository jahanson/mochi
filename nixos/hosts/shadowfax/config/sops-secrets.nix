{...}: {
  secrets = {
    # Minio
    "minio" = {
      sopsFile = ../secrets.sops.yaml;
      owner = "minio";
      group = "minio";
      mode = "400";
      restartUnits = ["minio.service"];
    };
    # Syncthing
    "syncthing/publicCert" = {
      sopsFile = ../secrets.sops.yaml;
      owner = "jahanson";
      mode = "400";
      restartUnits = ["syncthing.service"];
    };
    "syncthing/privateKey" = {
      sopsFile = ../secrets.sops.yaml;
      owner = "jahanson";
      mode = "400";
      restartUnits = ["syncthing.service"];
    };
    # Prowlarr
    "arr/prowlarr/apiKey" = {
      sopsFile = ../secrets.sops.yaml;
      owner = "prowlarr";
      mode = "400";
      restartUnits = ["prowlarr.service"];
    };
    "arr/prowlarr/postgres/dbName" = {
      sopsFile = ../secrets.sops.yaml;
      owner = "prowlarr";
      mode = "400";
      restartUnits = ["prowlarr.service"];
    };
    "arr/prowlarr/postgres/user" = {
      sopsFile = ../secrets.sops.yaml;
      owner = "prowlarr";
      mode = "400";
      restartUnits = ["prowlarr.service"];
    };
    "arr/prowlarr/postgres/password" = {
      sopsFile = ../secrets.sops.yaml;
      owner = "prowlarr";
      mode = "400";
      restartUnits = ["prowlarr.service"];
    };
    "arr/prowlarr/postgres/host" = {
      sopsFile = ../secrets.sops.yaml;
      owner = "prowlarr";
      mode = "400";
      restartUnits = ["prowlarr.service"];
    };
    # Sonarr
    "arr/sonarr/1080p/apiKey" = {
      sopsFile = ../secrets.sops.yaml;
      owner = "sonarr";
      mode = "400";
      restartUnits = ["sonarr-tv1080p.service"];
    };
    "arr/sonarr/1080p/postgres/dbName" = {
      sopsFile = ../secrets.sops.yaml;
      owner = "sonarr";
      mode = "400";
      restartUnits = ["sonarr-tv1080p.service"];
    };
    "arr/sonarr/1080p/postgres/user" = {
      sopsFile = ../secrets.sops.yaml;
      owner = "sonarr";
      mode = "400";
      restartUnits = ["sonarr-tv1080p.service"];
    };
    "arr/sonarr/1080p/postgres/password" = {
      sopsFile = ../secrets.sops.yaml;
      owner = "sonarr";
      mode = "400";
      restartUnits = ["sonarr-tv1080p.service"];
    };
    "arr/sonarr/1080p/postgres/host" = {
      sopsFile = ../secrets.sops.yaml;
      owner = "sonarr";
      mode = "400";
      restartUnits = ["sonarr-tv1080p.service"];
    };
    "arr/sonarr/1080p/extraEnvVars" = {
      sopsFile = ../secrets.sops.yaml;
      owner = "sonarr";
      mode = "400";
      restartUnits = ["sonarr-tv1080p.service"];
    };
    "arr/sonarr/anime/apiKey" = {
      sopsFile = ../secrets.sops.yaml;
      owner = "sonarr";
      mode = "400";
      restartUnits = ["sonarr-anime.service"];
    };
    "arr/sonarr/anime/postgres/dbName" = {
      sopsFile = ../secrets.sops.yaml;
      owner = "sonarr";
      mode = "400";
      restartUnits = ["sonarr-anime.service"];
    };
    "arr/sonarr/anime/postgres/user" = {
      sopsFile = ../secrets.sops.yaml;
      owner = "sonarr";
      mode = "400";
      restartUnits = ["sonarr-anime.service"];
    };
    "arr/sonarr/anime/postgres/password" = {
      sopsFile = ../secrets.sops.yaml;
      owner = "sonarr";
      mode = "400";
      restartUnits = ["sonarr-anime.service"];
    };
    "arr/sonarr/anime/postgres/host" = {
      sopsFile = ../secrets.sops.yaml;
      owner = "sonarr";
      mode = "400";
      restartUnits = ["sonarr-anime.service"];
    };
    "arr/sonarr/anime/extraEnvVars" = {
      sopsFile = ../secrets.sops.yaml;
      owner = "sonarr";
      mode = "400";
      restartUnits = ["sonarr-anime.service"];
    };
    # Radarr
    "arr/radarr/1080p/apiKey" = {
      sopsFile = ../secrets.sops.yaml;
      owner = "radarr";
      mode = "400";
      restartUnits = ["radarr-movies1080p.service"];
    };
    "arr/radarr/1080p/postgres/dbName" = {
      sopsFile = ../secrets.sops.yaml;
      owner = "radarr";
      mode = "400";
      restartUnits = ["radarr-movies1080p.service"];
    };
    "arr/radarr/1080p/postgres/user" = {
      sopsFile = ../secrets.sops.yaml;
      owner = "radarr";
      mode = "400";
      restartUnits = ["radarr-movies1080p.service"];
    };
    "arr/radarr/1080p/postgres/password" = {
      sopsFile = ../secrets.sops.yaml;
      owner = "radarr";
      mode = "400";
      restartUnits = ["radarr-movies1080p.service"];
    };
    "arr/radarr/1080p/postgres/host" = {
      sopsFile = ../secrets.sops.yaml;
      owner = "radarr";
      mode = "400";
      restartUnits = ["radarr-movies1080p.service"];
    };
    "arr/radarr/1080p/extraEnvVars" = {
      sopsFile = ../secrets.sops.yaml;
      owner = "radarr";
      mode = "400";
      restartUnits = ["radarr-movies1080p.service"];
    };
    "arr/radarr/anime/apiKey" = {
      sopsFile = ../secrets.sops.yaml;
      owner = "radarr";
      mode = "400";
      restartUnits = ["radarr-anime.service"];
    };
    "arr/radarr/anime/postgres/dbName" = {
      sopsFile = ../secrets.sops.yaml;
      owner = "radarr";
      mode = "400";
      restartUnits = ["radarr-anime.service"];
    };
    "arr/radarr/anime/postgres/user" = {
      sopsFile = ../secrets.sops.yaml;
      owner = "radarr";
      mode = "400";
      restartUnits = ["radarr-anime.service"];
    };
    "arr/radarr/anime/postgres/password" = {
      sopsFile = ../secrets.sops.yaml;
      owner = "radarr";
      mode = "400";
      restartUnits = ["radarr-anime.service"];
    };
    "arr/radarr/anime/postgres/host" = {
      sopsFile = ../secrets.sops.yaml;
      owner = "radarr";
      mode = "400";
      restartUnits = ["radarr-anime.service"];
    };
    "arr/radarr/anime/extraEnvVars" = {
      sopsFile = ../secrets.sops.yaml;
      owner = "radarr";
      mode = "400";
      restartUnits = ["radarr-anime.service"];
    };
    # Unpackerr
    "arr/unpackerr/extraEnvVars" = {
      sopsFile = ../secrets.sops.yaml;
      owner = "unpackerr";
      mode = "400";
      restartUnits = ["unpackerr.service"];
    };
    # Borgmatic
    "borgmatic/plex/encryption_passphrase" = {
      sopsFile = ../secrets.sops.yaml;
      mode = "400";
      restartUnits = ["borgmatic.service"];
    };
    "borgmatic/plex/append_key" = {
      sopsFile = ../secrets.sops.yaml;
      mode = "400";
      restartUnits = ["borgmatic.service"];
    };
    "borgmatic/jellyfin/encryption_passphrase" = {
      sopsFile = ../secrets.sops.yaml;
      mode = "400";
      restartUnits = ["borgmatic.service"];
    };
    "borgmatic/jellyfin/append_key" = {
      sopsFile = ../secrets.sops.yaml;
      mode = "400";
      restartUnits = ["borgmatic.service"];
    };
  };
}
