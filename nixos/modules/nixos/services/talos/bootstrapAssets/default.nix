{ lib, config, pkgs, ... }:
with lib;
let
  cfg = config.mySystem.services.talos.bootstrapAssets;
  download-undionly = pkgs.writeShellScript "download-undionly" import ./resources/download-undionly.sh;
in
{
  options.mySystem.services.talos.bootstrapAssets = {
    enable = mkEnableOption "talos.bootstrapAssets";
    bootAsset = mkOption {
      type = types.str;
      example = "http://10.1.1.57:8086/boot.ipxe";
    };
    tftpRoot = mkOption {
      type = types.str;
      example = "/srv/tftp";
    };
    matchboxDataPath = mkOption {
      type = types.str;
      example = "/var/lib/matchbox";
    };
    matchboxAssetPath = mkOption {
      type = types.str;
      example = "/var/lib/matchbox/assets";
    };
    talosSchematicIds = mkOption {
      type = types.listOf types.str;
      default = [ ];
      example = [ "22b1d04da881ef7c57edb0f24d1f3ba2c78a8e22cbe3fa9af4f42d487b2863f7" ];
    };
    talhelperConfig = mkOption {
      type = types.str;
      example = "/etc/talhelper/config.yaml";
    };
  };

  config = mkIf cfg.enable {
    # nix grab talconfig.yaml from git repo
    #
  };
}
