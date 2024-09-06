{ config, lib, pkgs, ... }:
# Role for workstations
# Covers desktops/laptops, expected to have a GUI and do workloads
# Will have home-manager installs

with config;
{
  mySystem = {
    de.gnome.enable = true;
    shell.fish.enable = true;
    editor.vscode.enable = true;

    system.resticBackup.local.enable = false;
    system.resticBackup.remote.enable = false;
  };

  boot = {
    binfmt.emulatedSystems = [ "aarch64-linux" ]; # Enabled for raspi4 compilation
    plymouth.enable = true; # hide console with splash screen
  };

  nix.settings = {
    # Avoid disk full issues
    max-free = lib.mkDefault (1000 * 1000 * 1000);
    min-free = lib.mkDefault (128 * 1000 * 1000);
  };

  services = {
    # set xserver videodrivers if used
    xserver.enable = true;
    # Enable the Gnome keyring for auto unlocking ssh keys on login
    gnome.gnome-keyring.enable = true;
    fwupd.enable = config.boot.loader.systemd-boot.enable; # fwupd does not work in BIOS mode
    thermald.enable = true;
    smartd.enable = true;
  };

  hardware = {
    enableAllFirmware = true;
    sensor.hddtemp = {
      enable = true;
      drives = [ "/dev/disk/by-id/*" ];
    };
  };

  environment.systemPackages = with pkgs; [
    # Sensors etc
    lm_sensors
    cpufrequtils
    cpupower-gui
    vivaldi
    gparted
    termius
  ];

  i18n = {
    defaultLocale = lib.mkDefault "en_US.UTF-8";
  };

  programs = {
    mtr.enable = true;
    ssh.startAgent = true;

    # Enable appimage support and executing them via the appimage-run helper.
    appimage = {
      enable = true;
      binfmt = true;
    };
  };
}
