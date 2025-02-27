{pkgs, ...}: {
  imports = [
    ./global.nix
  ];

  config = {
    myHome = {
      de.hyprland.enable = true;
      programs = {
        firefox.enable = true;
        thunderbird.enable = true;
      };
      shell = {
        # soon(tm)
        # ghostty.enable = true;

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
      packages = with pkgs; [
        # apps
        solaar # open source manager for logitech unifying receivers
        # unstable.vesktop # gpu issues. Using the flatpak version solves this issue.
        vlc
      ];
    };
  };
}
