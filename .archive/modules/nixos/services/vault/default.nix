{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.mySystem.services.vault;
in
{
  options.mySystem.services.vault = {
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
      storageBackend = "raft";
      extraConfig = ''
        api_addr = "http://127.0.0.1:8200"
        cluster_addr = "http://127.0.0.1:8201"
        ui = true
      '';
    };
  };
}
