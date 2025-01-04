{ ... }:
{
  outputs = {
    # ZFS automated snapshots
    templates = {
      "production" = {
        autoprune = true;
        autosnap = true;
        hourly = 24;
        daily = 7;
        monthly = 12;
      };
      "nvr" = {
        autoprune = true;
        autosnap = true;
        hourly = 24;
        daily = 7;
      };
    };
    datasets = {
      "nahar/scrypted" = {
        useTemplate = [ "nvr" ];
      };
      "nahar/containers/volumes/plex" = {
        useTemplate = [ "production" ];
        recursive = true;
      };
      "nahar/containers/volumes/scrypted" = {
        useTemplate = [ "production" ];
        recursive = true;
      };
      "nahar/containers/volumes/jellyfin" = {
        useTemplate = [ "production" ];
        recursive = true;
      };
      "nahar/containers/volumes/scrutiny" = {
        useTemplate = [ "production" ];
        recursive = true;
      };
    };
  };
}
