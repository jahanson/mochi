{
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.mySystem.services.openssh;
in {
  options.mySystem.services.openssh = {
    enable =
      mkEnableOption "openssh"
      // {
        default = true;
      };
    passwordAuthentication = mkOption {
      type = lib.types.bool;
      description = "If password can be accepted for ssh (commonly disable for security hardening)";
      default = false;
    };
    permitRootLogin = mkOption {
      type = types.enum [
        "yes"
        "without-password"
        "prohibit-password"
        "forced-commands-only"
        "no"
      ];
      description = "If root can login via ssh (commonly disable for security hardening)";
      default = "prohibit-password";
    };
  };

  config = mkIf cfg.enable {
    services.openssh = {
      enable = true;
      openFirewall = true;
      settings = {
        # Harden
        PasswordAuthentication = cfg.passwordAuthentication;
        PermitRootLogin = cfg.permitRootLogin;
        # Automatically remove stale sockets
        StreamLocalBindUnlink = "yes";
        # Allow forwarding ports to everywhere
        GatewayPorts = "clientspecified";
      };
    };
  };
}
