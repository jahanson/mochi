{ pkgs, config, ... }:
with config;
{
  imports = [
    ./global.nix
  ];

  myHome = {
    programs.firefox.enable = true;
    shell = {
      wezterm.enable = true;

      git = {
        enable = true;
        username = "Joseph Hanson";
        email = "joe@veri.dev";
        signingKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIDSAmssproxG+KsVn2DfuteBAemHrmmAFzCtldpKl4J";
      };
    };
  };

  home = {
    # Install these packages for my user
    packages = with pkgs;
      [
        #apps
        discord
        flameshot
        jetbrains.datagrip
        obsidian
        parsec-bin
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
