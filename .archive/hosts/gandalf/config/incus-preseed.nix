{...}: {
  config = {
    "core.https_address" = "10.1.1.15:8445"; # Need quotes around key
  };
  networks = [
    {
      config = {
        "ipv4.address" = "auto"; # Need quotes around key
        "ipv6.address" = "auto"; # Need quotes around key
      };
      description = "";
      name = "incusbr0";
      type = "";
      project = "default";
    }
  ];
  storage_pools = [
    {
      config = {
        source = "eru/incus";
      };
      description = "";
      name = "default";
      driver = "zfs";
    }
  ];
  profiles = [
    {
      config = {};
      description = "";
      devices = {
        eth0 = {
          name = "eth0";
          network = "incusbr0";
          type = "nic";
        };
        root = {
          path = "/";
          pool = "default";
          type = "disk";
        };
      };
      name = "default";
    }
  ];
  projects = [];
  cluster = null;
}
