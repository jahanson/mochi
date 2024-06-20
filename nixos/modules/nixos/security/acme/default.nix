{ lib, config, ... }:
with lib;
let
  cfg = config.mySystem.security.acme;
in
{
  options.mySystem.security.acme.enable = mkEnableOption "acme";

  config = mkIf cfg.enable {
    sops.secrets = {
      "security/acme/env".sopsFile = ./secrets.sops.yaml;
      "security/acme/env".restartUnits = [ "lego.service" ];
    };

    environment.persistence."${config.mySystem.system.impermanence.persistPath}" = lib.mkIf config.mySystem.system.impermanence.enable {
      directories = [ "/var/lib/acme" ];
    };

    security.acme = {
      acceptTerms = true;
      defaults.email = "admin@${config.networking.domain}";

      certs.${config.networking.domain} = {
        extraDomainNames = [
          "${config.networking.domain}"
          "*.${config.networking.domain}"
        ];
        dnsProvider = "cloudflare";
        dnsResolver = "1.1.1.1:53";
        credentialsFile = config.sops.secrets."security/acme/env".path;
      };
    };


  };
}
