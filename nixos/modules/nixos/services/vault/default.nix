{ config, lib, pkgs, ... }:
let
  cfg = config.mySystem.vault;
in
{
  options.vault = {
    enable = lib.mkEnableOption "vault";
    address = lib.mkOption {
      type = lib.types.str;
      default = "127.0.0.1:8200";
      description = "Address of the Vault server";
      example = "127.0.0.1:8200";
    };
  };

  config = lib.mkIf cfg.enable {
    services.vault = {
      enable = true;
      package = pkgs.unstable.vault;
      address = cfg.address;
      dev = false;
      storage = "raft";
    };
  };
}
