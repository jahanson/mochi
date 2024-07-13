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
      "eru/xen-backups" = {
        useTemplate = ["production"];
      };
      "eru/hansonhive" = {
        useTemplate = ["production"];
      };
      "eru/tm_joe" = {
        useTemplate = ["production"];
      };
      "eru/tm_elisia" = {
        useTemplate = ["production"];
      };
      "eru/containers/volumes/xo-data" = {
        useTemplate = ["production"];
      };
      "eru/containers/volumes/xo-redis-data" = {
        useTemplate = ["production"];
      };
    };
  };
}
