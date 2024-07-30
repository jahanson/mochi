{ pkgs, config, lib, ... }:
let
  cfg = config.myHome.shell.git;
in
{
  options.myHome.shell.git = {
    enable = lib.mkEnableOption "git";
    username = lib.mkOption {
      type = lib.types.str;
    };
    email = lib.mkOption {
      type = lib.types.str;
    };
    signingKey = lib.mkOption {
      type = lib.types.str;
    };
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.enable {
      programs = {
        gh.enable = true;
        gpg.enable = true;
        git = {
          enable = true;

          userName = cfg.username;
          userEmail = cfg.email;

          extraConfig = {
            core.autocrlf = "input";
            init.defaultBranch = "main";
            pull.rebase = true;
            rebase.autoStash = true;
            # public key for signing commits
            user.signingKey = cfg.signingKey;
            # ssh instead of gpg
            gpg.format = "ssh";
            # 1password signing gui git signing
            gpg.ssh.program = "${pkgs._1password-gui}/bin/op-ssh-sign";
            # Auto sign commits without -S
            commit.gpgsign = true;
          };
          aliases = {
            co = "checkout";
          };
          ignores = [
            # Mac OS X hidden files
            ".DS_Store"
            # Windows files
            "Thumbs.db"
            # asdf
            ".tool-versions"
            # Sops
            ".decrypted~*"
            "*.decrypted.*"
            # Python virtualenvs
            ".venv"
          ];
        };
      };

      home.packages = [
        pkgs.git-filter-repo
        pkgs.tig
        pkgs.lazygit
      ];
    })
  ];
}
