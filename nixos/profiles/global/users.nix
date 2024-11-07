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

  users = {
    groups = {
      kah = {
        gid = 568;
      };
    };
    users = {
      kah = {
        isSystemUser = true;
        group = "kah";
        uid = 568;
      };

      jahanson = {
        isNormalUser = true;
        shell = pkgs.fish;
        hashedPasswordFile = config.sops.secrets.jahanson-password.path;
        extraGroups =
          [
            "wheel"
            "kah"
          ]
          ++ ifTheyExist [
            "network"
            "samba-users"
            "docker"
            "podman"
            "audio" # pulseaudio
            "libvirtd"
            "wireshark"
            "minecraft"
            "syncthing"
          ];

        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIDJtqzSFK3MN12Lo3Y4DnzJV5NiygIPkR+gun5oEb2q jahanson@legiondary"
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBsUe5YF5z8vGcEYtQX7AAiw2rJygGf2l7xxr8nZZa7w jahanson@durincore"
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILcLI5qN69BuoLp8p7nTYKoLdsBNmZB31OerZ63Car1g jahanson@telchar"
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHwUOBEd0z2Jh6qJi4JeJbWdbU665E8/cP44iaUjW1DA jahanson@shadowfax"
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPHzVi4xC6aLYsC4iiIX9rBfEh/FkWZilukLxmfjU9DE jahanson@gandalf"
        ];
      };
    };
  };
}
