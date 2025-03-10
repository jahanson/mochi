{
  pkgs,
  inputs,
  ...
}: {
  imports = [];
  swapDevices = [];
  virtualisation.docker.enable = true;

  # System packages
  environment = {
    sessionVariables = {
      # Wayland and Chromium/Electron apps.
      NIXOS_OZONE_WL = "1";
    };
    systemPackages = with pkgs; [
      # myPkgs.modrinth-app-unwrapped
      inputs.zen-browser.packages."${system}".default # beta
      inputs.ghostty.packages."${system}".default # terminal
      dconf-editor
      fastfetch
      gtk3
      nodejs_22
      pavucontrol # Pulseaudio volume control
      vesktop # Discord custom client
      zulu # Java OpenJDK
    ];
  };

  services = {
    # Tailscale
    tailscale = {
      enable = true;
      openFirewall = true;
    };
    # Pipewire and Pulseaudio
    pipewire = {
      enable = true;
      alsa.enable = true;
      pulse.enable = true;
      extraConfig.pipewire = {
        "10-clock-rate" = {
          "context.properties" = {
            "default.clock.rate" = 48000;
          };
        };
        "10-clock-quantum" = {
          "context.properties" = {
            "default.clock.quantum" = 1024;
          };
        };
      };
    };
    blueman.enable = true;
  };

  ## System settings and services.
  mySystem = {
    purpose = "Development";

    #services.syncthing = {
    #  enable = false;
    #  user = "jahanson";
    #  publicCertPath = config.sops.secrets."syncthing/publicCert".path;
    #  privateKeyPath = config.sops.secrets."syncthing/privateKey".path;
    #};

    ## Desktop Environment
    ## Gnome
    # de.gnome.enable = true;
    ## KDE
    # de.kde.enable = true;
    ## Hyprland
    de.hyprland.enable = true;

    ## Games
    # games.steam.enable = true;

    ## System config
    system = {
      motd.networkInterfaces = ["wlp1s0"];
      fingerprint-reader-on-laptop-lid.enable = true;
    };

    framework_wifi_swap.enable = true;
    security._1password.enable = true;
  };
}
