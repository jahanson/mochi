{ config, lib, ... }:
with lib; let
  cfg = config.mySystem.security._1password;
  user = "jahanson";
in
{
  options.mySystem.security._1password = {
    enable = mkEnableOption "_1password";
  };

  config = mkIf cfg.enable {
    programs = {
      _1password.enable = true;
      _1password-gui = {
        enable = true;
        polkitPolicyOwners = [ "${user}" ];
      };
    };

    home-manager.users.${user} = {
      home.file = {
        ".config/autostart/1password-startup.desktop".source = ./config/1password-startup.desktop;
      };
    };

    environment.etc = {
      "1password/custom_allowed_browsers" = {
        text = ''
          vivaldi-bin
        '';
        mode = "0755";
      };
    };
  };
}
