{ lib, config, ... }:
with lib;
let
  app = "lego-auto";
  image = "ghcr.io/bjw-s/lego-auto:v0.3.0";
  user = "999"; # string
  group = "102"; # string
  port = 9898; # int
  cfg = config.mySystem.services.${app};
  appFolder = "/eru/containers/volumes/${app}";
in
{
  options.mySystem.services.${app} = {
    enable = mkEnableOption "${app}";
    dnsimpleTokenPath = mkOption {
      type = types.path;
      example = "/config/dnsimple-token";
      description = "Path to the DNSimple token file";
    };
    provider = mkOption {
      type = types.str;
      example = "dnsimple";
      description = "DNS provider";
    };
    domains = mkOption {
      type = types.str;
      example = "gandalf.jahanson.tech";
      description = "Domains to manage";
    };
    email = mkOption {
      type = types.str;
      example = "joe@veri.dev";
      description = "Email address for Let's Encrypt";
    };
  };

  # TODO: Add refresh cert path (ex. copy cert to unifi)
  config = mkIf cfg.enable {
    virtualisation.oci-containers.containers.${app} = {
      image = "${image}";
      user = "${user}:${group}";
      autoStart = true;
      extraOptions = [
        "--dns=1.1.1.1"
      ];
      environment =
        {
          TZ = "America/Chicago";
          LA_DATADIR = "/cert";
          LA_CACHEDIR = "/cert/.cache";
          LA_EMAIL = cfg.email;
          LA_DOMAINS = cfg.domains;
          LA_PROVIDER = cfg.provider;
        }
        // lib.optionalAttrs (cfg.provider == "dnsimple") {
          DNSIMPLE_OAUTH_TOKEN_FILE = "/config/dnsimple-token";
        };

      volumes = [
        "${appFolder}/cert:/cert"
      ] ++ optionals (cfg.provider == "dnsimple") [ "${cfg.dnsimpleTokenPath}:/config/dnsimple-token" ];
    };
  };
}
