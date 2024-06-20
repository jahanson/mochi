{ pkgs, config, ... }:
let
  ifTheyExist = groups: builtins.filter (group: builtins.hasAttr group config.users.groups) groups;
in
{
  sops.secrets = {
    jahanson-password = {
      sopsFile = ./secrets.sops.yaml;
      neededForUsers = true;
    };
  };

  users.users.jahanson = {
    isNormalUser = true;
    shell = pkgs.fish;
    hashedPasswordFile = config.sops.secrets.jahanson-password.path;
    extraGroups =
      [
        "wheel"
      ]
      ++ ifTheyExist [
        "network"
        "samba-users"
        "docker"
        "podman"
        "audio" # pulseaudio
        "libvirtd"
      ];

    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBsUe5YF5z8vGcEYtQX7AAiw2rJygGf2l7xxr8nZZa7w"
      "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBH3VVFenoJfnu+IFUlD79uxl7L8SFoRup33J2HGny4WEdRgGR41s0MpFKDBmxXZHy4O9Nh8NMMnpy5VhUefnIKI="
      "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBPHFQ3hDjjrKsecn3jmSWYlRXy4IJCrepgU1HaIV5VcmB3mUFmIZ/pCZnPmIG/Gbuqf1PP2FQDmHMX5t0hTYG9A="
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIETR70eQJiXaJuB+qpI1z+jFOPbEZoQNRcq4VXkojWfU"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIATyScd8ZRhV7uZmrQNSAbRTs9N/Dbx+Y8tGEDny30sA"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJyA/yMPPo+scxBaDFUk7WeEyMAMhXUro5vi4feOKsJT jahanson@durincore"
    ];
  };
}
