{
  config,
  pkgs,
  myPkgs,
  inputs,
  ...
}: let
  hypr-pkgs = inputs.hyprland.inputs.nixpkgs.legacyPackages.${pkgs.stdenv.hostPlatform.system};
in {
  imports = [];
  swapDevices = [];
  virtualisation.docker.enable = true;

  # System packages
  environment.systemPackages = with pkgs; [
    uv
    fastfetch
    gtk3
    dconf-editor
    # myPkgs.modrinth-app-unwrapped
    zulu # Java OpenJDK
    nodejs_22
    vesktop
  ];

  hardware.graphics = {
    package = hypr-pkgs.mesa.drivers;
  };

  environment.sessionVariables = {
    # Wayland and Chromium/Electron apps.
    NIXOS_OZONE_WL = "1";
  };

  # sops
  #  sops.secrets = {
  #  "syncthing/publicCert" = {
  #    sopsFile = ./secrets.sops.yaml;
  #    owner = "jahanson";
  #    mode = "400";
  #    restartUnits = ["syncthing.service"];
  #  };
  #  "syncthing/privateKey" = {
  #    sopsFile = ./secrets.sops.yaml;
  #    owner = "jahanson";
  #    mode = "400";
  #    restartUnits = ["syncthing.service"];
  #  };
  #};

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
      jack.enable = true;
      pulse.enable = true;
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
