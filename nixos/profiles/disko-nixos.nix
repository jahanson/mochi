{ disks ? [ "/dev/sda" ], ... }: {
  disko.devices = {
    disk = {
      main = {
        type = "disk";
        device = builtins.elemAt disks 0;
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              size = "1024M";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
              };
            };
            zfs = {
              size = "100%";
              content = {
                type = "zfs";
                pool = "zroot";
              };
            };
          };
        };
      };
    };
    zpool = {
      zroot = {
        type = "zpool";
        mode = "";
        rootFsOptions = {
          compression = "zstd";
          "com.sun:auto-snapshot" = "false";
          mountpoint = "none";
          acltype = "posixacl";
        };

        postCreateHook = "zfs list -t snapshot -H -o name | grep -E '^zroot@blank$' || zfs snapshot zroot@blank";

        datasets = {
          root = {
            type = "zfs_fs";
            mountpoint = "/";
            options = {
              ashift = 12;
              zfsutil = "";
            };
          };

          nix = {
            type = "zfs_fs";
            mountpoint = "/nix";
            options = {
              ashift = 12;
              zfsutil = "";
            };
          };

          var = {
            type = "zfs_fs";
            mountpoint = "/var";
            options = {
              ashift = 12;
              zfsutil = "";
            };
          };

          home = {
            type = "zfs_fs";
            mountpoint = "/home";
            options = {
              ashift = 12;
              "com.sun:auto-snapshot" = "true";
              zfsutil = "";
            };
          };
        };
      };
    };
  };
}
