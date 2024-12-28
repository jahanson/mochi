{ ... }:
{
  outputs = {
    # ZFS automated snapshots
    templates = {
      "production" = {
        recursive = true;
        autoprune = true;
        autosnap = true;
        hourly = 24;
        daily = 7;
        monthly = 12;
      };
    };
    datasets = {
      "nahar/scrypted" = {
        useTemplate = [ "production" ];
      };
      "nahar/containers/volumes/plex" = {
        useTemplate = [ "production" ];
      };
      "nahar/containers/volumes/scrypted" = {
        useTemplate = [ "production" ];
      };
      "nahar/containers/volumes/jellyfin" = {
        useTemplate = [ "production" ];
      };
      "nahar/containers/volumes/scrutiny" = {
        useTemplate = [ "production" ];
      };
    };
  };
}
