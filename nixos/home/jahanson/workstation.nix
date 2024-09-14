{ pkgs, config, inputs, ... }:
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
        #apps
        (unstable.flameshot.override { enableWlrSupport = true; })
        obsidian
        parsec-bin
        solaar # open source manager for logitech unifying receivers
        unstable.bruno
        unstable.fractal
        unstable.httpie
        unstable.jetbrains.datagrip
        unstable.peazip
        unstable.seabird
        unstable.talosctl
        unstable.telegram-desktop
        unstable.tidal-hifi
        unstable.vault
        unstable.vesktop
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
      ];
  };
}
