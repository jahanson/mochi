{pkgs, ...}: {
  imports = [
    ./global.nix
  ];
  config = {
    # Custom Home Manager Configuration
    myHome = {
      de.hyprland.enable = true;
      programs = {
        firefox.enable = true;
        thunderbird.enable = true;
      };
      shell = {
        git = {
          enable = true;
          username = "Joseph Hanson";
          email = "joe@veri.dev";
          signingKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIDSAmssproxG+KsVn2DfuteBAemHrmmAFzCtldpKl4J";
        };
      };
    };

    # Home Manager Configuration
    home = {
      # Install these packages for my user
      packages = with pkgs; [
        # apps
        # parsec-bin
        solaar # open source manager for logitech unifying receivers
        unstable.bruno
        # unstable.fractal
        unstable.obsidian
        unstable.httpie
        unstable.jetbrains.datagrip
        unstable.jetbrains.rust-rover
        unstable.seabird
        unstable.talosctl # overlay override
        unstable.telegram-desktop
        unstable.tidal-hifi
        # unstable.xpipe
        # unstable.vesktop # gpu issues. Using the flatpak version solves this issue.
        vlc
        yt-dlp

        # cli
        brightnessctl
      ];
    };
  };
}
