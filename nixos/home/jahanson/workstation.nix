{ pkgs, config, inputs, ... }:
let
  coderMainline = pkgs.coder.override { channel = "mainline"; };
in
with config;
{
  imports = [
    ./global.nix
    inputs.krewfile.homeManagerModules.krewfile
  ];

  # Krewfile management
  programs.krewfile = {
    enable = true;
    krewPackage = pkgs.krew;
    indexes = {
      "netshoot" = "https://github.com/nilic/kubectl-netshoot.git";
    };
    plugins = [
      "netshoot/netshoot"
      "resource-capacity"
      "rook-ceph"
    ];
  };

  myHome = {
    programs.firefox.enable = true;
    programs.thunderbird.enable = true;
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
        # apps
        obsidian
        parsec-bin
        solaar # open source manager for logitech unifying receivers
        talosctl # overlay override
        unstable.bruno
        unstable.fractal
        unstable.httpie
        unstable.jetbrains.datagrip
        unstable.jetbrains.rust-rover
        unstable.peazip
        unstable.seabird
        unstable.telegram-desktop
        unstable.tidal-hifi
        # unstable.vesktop # gpu issues. Using the flatpak version solves this issue.
        vlc
        yt-dlp

        # cli
        brightnessctl

        # dev utils
        kubectl
        minio-client # S3 management
        pre-commit # Pre-commit tasks for git
        shellcheck # shell script linting
        unstable.act # run GitHub actions locally
        unstable.nodePackages_latest.prettier # code formatter
        unstable.tailspin # logfile highlighter
        coderMainline # VSCode in the browser -- has overlay
      ];
  };
}
