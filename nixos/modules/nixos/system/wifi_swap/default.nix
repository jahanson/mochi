# turns off the wifi when the usb device 0bda:8156 is connected.
{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.mySystem.framework_wifi_swap;
  wifiSwap = pkgs.writeShellScriptBin "wifi_swap" ''
    #! /usr/bin/env bash
    # This script turns off the wifi and on when the usb device 0bda:8156 is connected or removed.
    # It is useful when you want to use a wired connection instead of wifi.
    # The script is run by udev when the usb device is connected.
    # The script is located at /run/current-system/sw/bin/wifi_swap
    # The udev rule is located at <nix-store>-extra-udev-rules/etc/udev/rules.d/99-local.rules
    # The udev rule is:
    # ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="0bda", ATTR{idProduct}=="8156", RUN+="/run/current-system/sw/bin/wifi_swap"
    # ACTION=="remove", SUBSYSTEM=="net", ENV{ID_USB_VENDOR_ID}=="0bda", ENV{ID_USB_MODEL_ID}=="8156", RUN+="/run/current-system/sw/bin/wifi_swap"
    echo "wifi_swap ACTION: $ACTION" | systemd-cat -t wifi_swap
    # Case or switch for $ACTION
    case $ACTION in
      add)
        echo "Plugged in USB device 0bda:8156 (Realtek 2.5gbe). Turning Wi-Fi off." | systemd-cat -t wifi_swap
        ${pkgs.networkmanager.outPath}/bin/nmcli radio wifi off
        ;;
      remove)
        echo "unplugged in USB device 0bda:8156 (Realtek 2.5gbe) Turning Wi-Fi on." | systemd-cat -t wifi_swap
        ${pkgs.networkmanager.outPath}/bin/nmcli radio wifi on
        ;;
      *)
        echo "Uknown ACTION: $ACTION" | systemd-cat -t wifi_swap
        ;;
    esac
  '';
in {
  options.mySystem.framework_wifi_swap = {
    enable =
      mkEnableOption "framework_wifi_swap"
      // {
        default = false;
      };
  };
  config = mkIf cfg.enable {
    # Create bash script and add it to nix store
    environment.systemPackages = [
      wifiSwap
    ];

    # Add udev rule to run script when usb device 0bda:8156 is connected or disconnected.
    services.udev.extraRules = ''
      ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="0bda", ATTR{idProduct}=="8156", RUN+="${wifiSwap.outPath}/bin/wifi_swap"
      ACTION=="remove", SUBSYSTEM=="net", ENV{ID_USB_VENDOR_ID}=="0bda", ENV{ID_USB_MODEL_ID}=="8156", RUN+="${wifiSwap.outPath}/bin/wifi_swap"
    '';
  };
}
