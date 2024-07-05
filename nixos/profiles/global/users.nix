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
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIDJtqzSFK3MN12Lo3Y4DnzJV5NiygIPkR+gun5oEb2q jahanson@legiondary"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBsUe5YF5z8vGcEYtQX7AAiw2rJygGf2l7xxr8nZZa7w jahanson@durincore"
    ];
  };
}
