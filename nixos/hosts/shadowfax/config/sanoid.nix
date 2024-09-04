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
    datasets = { };
  };
}
