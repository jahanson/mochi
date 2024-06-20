{ config, lib, pkgs, ... }:
# Role for workstations
# Covers desktops/laptops, expected to have a GUI and do workloads
# Will have home-manager installs

with config;
{
  mySystem = {

    de.gnome.enable = true;

    # Lets see if fish everywhere is OK on the pi's
    # TODO decide if i drop to bash on pis?
    shell.fish.enable = true;

    system.resticBackup.local.enable = false;
    system.resticBackup.remote.enable = false;
  };

  boot = {
    binfmt.emulatedSystems = [ "aarch64-linux" ]; # Enabled for raspi4 compilation
    plymouth.enable = true; # hide console with splash screen
  };

  nix.settings = {
    # TODO factor out into mySystem
    # Avoid disk full issues
    max-free = lib.mkDefault (1000 * 1000 * 1000);
    min-free = lib.mkDefault (128 * 1000 * 1000);
  };

  # set xserver videodrivers if used
  services.xserver.enable = true;

  services = {
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
    vscode
    vivaldi
    termius
  ];

  i18n = {
    defaultLocale = lib.mkDefault "en_US.UTF-8";
  };

  programs.mtr.enable = true;
}
