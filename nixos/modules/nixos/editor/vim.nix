# /home/jahanson/projects/mochi/nixos/modules/nixos/editor/vim.nix
{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.mySystem.editor.vim;
  users = ["jahanson"];
in {
  options.mySystem.editor.vim.enable = mkEnableOption "vim";
  config = mkIf cfg.enable {
    # Enable vim and set as default editor
    programs.vim.enable = true;
    programs.vim.defaultEditor = true;

    # Visual mode off and syntax highlighting on
    home-manager.users =
      mapAttrs
      (user: _: {
        home.file.".vimrc".text = ''
          set mouse-=a
          syntax on
        '';
      })
      (
        listToAttrs (
          map (u: {
            name = u;
            value = {};
          })
          users
        )
      );
  };
}
