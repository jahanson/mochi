{ lib, config, pkgs, ... }:
with lib;
let
  cfg = config.mySystem.editor.vscode;
in
{
  options.mySystem.editor.vscode.enable = mkEnableOption "vscode";
  config = mkIf cfg.enable {

    # Enable vscode & addons
    environment.systemPackages = with pkgs; [
      (vscode-with-extensions.override {
        vscode = unstable.vscode;

        vscodeExtensions = with vscode-extensions;
          [
            dracula-theme.theme-dracula
            yzhang.markdown-all-in-one
            signageos.signageos-vscode-sops
            redhat.ansible
            ms-azuretools.vscode-docker
            mikestead.dotenv
            tamasfe.even-better-toml
            pkief.material-icon-theme
            jnoortheen.nix-ide
            ms-vscode-remote.remote-ssh
            ms-vscode-remote.remote-ssh-edit
            # ms-vscode.remote-explorer
            redhat.vscode-yaml
            continue.continue
          ];
      })
    ];
  };
}
