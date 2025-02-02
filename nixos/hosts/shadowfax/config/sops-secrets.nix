{ ... }:
{
  secrets = {
    # Minio
    "minio" = {
      sopsFile = ../secrets.sops.yaml;
      owner = "minio";
      group = "minio";
      mode = "400";
      restartUnits = [ "minio.service" ];
    };
    # Syncthing
    "syncthing/publicCert" = {
      sopsFile = ../secrets.sops.yaml;
      owner = "jahanson";
      mode = "400";
      restartUnits = [ "syncthing.service" ];
    };
    "syncthing/privateKey" = {
      sopsFile = ../secrets.sops.yaml;
      owner = "jahanson";
      mode = "400";
      restartUnits = [ "syncthing.service" ];
    };
    # Prowlarr
    "arr/prowlarr/apiKey" = {
      sopsFile = ../secrets.sops.yaml;
      owner = "prowlarr";
      mode = "400";
      restartUnits = [ "prowlarr.service" ];
    };
    "arr/prowlarr/postgres/dbName" = {
      sopsFile = ../secrets.sops.yaml;
      owner = "prowlarr";
      mode = "400";
      restartUnits = [ "prowlarr.service" ];
    };
    "arr/prowlarr/postgres/user" = {
      sopsFile = ../secrets.sops.yaml;
      owner = "prowlarr";
      mode = "400";
      restartUnits = [ "prowlarr.service" ];
    };
    "arr/prowlarr/postgres/password" = {
      sopsFile = ../secrets.sops.yaml;
      owner = "prowlarr";
      mode = "400";
      restartUnits = [ "prowlarr.service" ];
    };
    "arr/prowlarr/postgres/host" = {
      sopsFile = ../secrets.sops.yaml;
      owner = "prowlarr";
      mode = "400";
      restartUnits = [ "prowlarr.service" ];
    };
    # # Sonarr
    # "arr/sonarr/apiKey" = {
    #   sopsFile = ../secrets.sops.yaml;
    #   owner = "sonarr";
    #   mode = "400";
    #   restartUnits = [ "sonarr.service" ];
    # };
    # "arr/sonarr/postgres/dbName" = {
    #   sopsFile = ../secrets.sops.yaml;
    #   owner = "sonarr";
    #   mode = "400";
    #   restartUnits = [ "sonarr.service" ];
    # };
    # "arr/sonarr/postgres/user" = {
    #   sopsFile = ../secrets.sops.yaml;
    #   owner = "sonarr";
    #   mode = "400";
    #   restartUnits = [ "sonarr.service" ];
    # };
    # "arr/sonarr/postgres/password" = {
    #   sopsFile = ../secrets.sops.yaml;
    #   owner = "sonarr";
    #   mode = "400";
    #   restartUnits = [ "sonarr.service" ];
    # };
    # # Radarr
    # "arr/radarr/apiKey" = {
    #   sopsFile = ../secrets.sops.yaml;
    #   owner = "radarr";
    #   mode = "400";
    #   restartUnits = [ "radarr.service" ];
    # };
    # "arr/radarr/postgres/dbName" = {
    #   sopsFile = ../secrets.sops.yaml;
    #   owner = "radarr";
    #   mode = "400";
    #   restartUnits = [ "radarr.service" ];
    # };
    # "arr/radarr/postgres/user" = {
    #   sopsFile = ../secrets.sops.yaml;
    #   owner = "radarr";
    #   mode = "400";
    #   restartUnits = [ "radarr.service" ];
    # };
    # "arr/radarr/postgres/password" = {
    #   sopsFile = ../secrets.sops.yaml;
    #   owner = "radarr";
    #   mode = "400";
    #   restartUnits = [ "radarr.service" ];
    # };
  };
}
