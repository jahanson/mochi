{ pkgs, config, ... }:
with config;
{
  imports = [
    ./global.nix
  ];

  myHome.programs.firefox.enable = true;

  myHome.shell = {
    starship.enable = true;
    fish.enable = true;
    wezterm.enable = true;
    atuind.enable = true;

    git = {
      enable = true;
      username = "Joseph Hanson";
      email = "joe@veri.dev";
      signingKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIDSAmssproxG+KsVn2DfuteBAemHrmmAFzCtldpKl4J";
    };
  };

  home = {
    # Install these packages for my user
    packages = with pkgs;
      [
        #apps
        _1password-gui
        discord
        flameshot
        jetbrains.datagrip
        obsidian
        parsec-bin
        pika-backup
        talosctl
        termius
        unstable.nheko
        unstable.telegram-desktop
        vlc

        # cli
        brightnessctl

        # dev utils
        minio-client # S3 management
        pre-commit # Pre-commit tasks for git
        shellcheck # shell script linting
        unstable.act
      ];
  };
}
