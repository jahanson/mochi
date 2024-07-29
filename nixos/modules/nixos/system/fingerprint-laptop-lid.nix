# Originally this file was based on
# https://unix.stackexchange.com/questions/678609/how-to-disable-fingerprint-authentication-when-laptop-lid-is-closed
# However I found this not to work as the fprintd is started via dbus and masking it doesn't seem to do anything.
# Another option to mess with pam.d:
# https://github.com/NixOS/nixpkgs/issues/171136#issuecomment-1690517722
# see: https://github.com/dani0854/nixos-vidar/blob/e7522ec353d0caf3dfc6779cc577c2a61318d264/config/core/doas.nix#L20
#
# On framework 13 the USB is:
# Port 004: Dev 003, If 0, Class=Vendor Specific Class, Driver=[none], 12M
# ID 27c6:609c Shenzhen Goodix Technology Co.,Ltd
{ config, lib, pkgs, ... }:
let
  cfg = config.mySystem.system.fingerprint-reader-on-laptop-lid;
  laptop-lid = pkgs.writeShellScript "laptop-lid" ''
    lock=$HOME/fingerprint-reader-disabled

    # match for either display port or hdmi port
    if grep -Fq closed /proc/acpi/button/lid/LID0/state &&
       (grep -Fxq connected /sys/class/drm/card1-DP-*/status ||
        grep -Fxq connected /sys/class/drm/card1-HDMI-*/status)
    then
      touch "$lock"
      echo 0 > /sys/bus/usb/devices/1-4/authorized
    elif [ -f "$lock" ]
    then
      echo 1 > /sys/bus/usb/devices/1-4/authorized
      rm "$lock"
    fi
  '';
in
{
  options.mySystem.system.fingerprint-reader-on-laptop-lid = {
    enable = lib.mkEnableOption "disable fingerprint reader when laptop lid closes";
  };

  config = lib.mkIf cfg.enable {
    services.acpid = {
      enable = true;
      lidEventCommands = "${laptop-lid}";
    };

    # Disable fingerprint reader at login since you can't put in a password when fprintd is running.
    security.pam.services.login.fprintAuth = false;
    # This is part of a fix for the fingerprint reader on the Framework 13/16 laptop so you can login without the fingerprint reader when the lid is closed.
    security.pam.services.gdm-fingerprint = lib.mkIf config.services.fprintd.enable {
      text = ''
        auth       required                    pam_shells.so
        auth       requisite                   pam_nologin.so
        auth       requisite                   pam_faillock.so      preauth
        auth       required                    ${pkgs.fprintd}/lib/security/pam_fprintd.so
        auth       optional                    pam_permit.so
        auth       required                    pam_env.so
        auth       [success=ok default=1]      ${pkgs.gnome.gdm}/lib/security/pam_gdm.so
        auth       optional                    ${pkgs.gnome.gnome-keyring}/lib/security/pam_gnome_keyring.so

        account    include                     login

        password   required                    pam_deny.so

        session    include                     login
        session    optional                    ${pkgs.gnome.gnome-keyring}/lib/security/pam_gnome_keyring.so auto_start
      '';
    };

    systemd.services.fingerprint-laptop-lid = {
      enable = true;
      description = "Disable fingerprint reader when laptop lid closes";
      serviceConfig = { ExecStart = "${laptop-lid}"; };
      wantedBy = [ "multi-user.target" "suspend.target" ];
      after = [ "suspend.target" ];
    };
  };
}
