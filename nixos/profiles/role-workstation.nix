{
  config,
  lib,
  pkgs,
  ...
}:
# Role for workstations
# Covers desktops/laptops, expected to have a GUI and do workloads
# Will have home-manager installs
let
  vivaldiOverride = pkgs.vivaldi.override {
    proprietaryCodecs = true;
    enableWidevine = true;
  };
in
  with config; {
    mySystem = {
      shell.fish.enable = true;
      editor.vscode.enable = true;
    };

    boot = {
      binfmt.emulatedSystems = ["aarch64-linux"]; # Enabled for compiling aarch64 binaries on x86_64
    };

    nix.settings = {
      # Avoid disk full issues
      max-free = lib.mkDefault (1000 * 1000 * 1000);
      min-free = lib.mkDefault (128 * 1000 * 1000);
    };

    services = {
      thermald.enable = true;
      smartd.enable = true;
      # Enable Flatpak support
      flatpak.enable = true;
    };

    hardware = {
      enableAllFirmware = true;
      sensor.hddtemp = {
        enable = true;
        drives = ["/dev/disk/by-id/*"];
      };
    };

    environment.systemPackages = with pkgs; [
      # Sensors etc
      lm_sensors
      cpufrequtils
      cpupower-gui
      gparted
      # Browser
      vivaldiOverride
    ];

    i18n = {
      defaultLocale = lib.mkDefault "en_US.UTF-8";
    };

    programs = {
      # Enable OpenJDK
      java.enable = true;

      # Enable appimage support and executing them via the appimage-run helper.
      appimage = {
        enable = true;
        binfmt = true;
      };
    };
  }
