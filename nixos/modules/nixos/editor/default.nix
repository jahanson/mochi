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

        vscodeExtensions =
          [
            vscode-extensions.dracula-theme.theme-dracula
            vscode-extensions.yzhang.markdown-all-in-one
            vscode-extensions.signageos.signageos-vscode-sops
            vscode-extensions.redhat.ansible
            vscode-extensions.ms-azuretools.vscode-docker
            vscode-extensions.mikestead.dotenv
            vscode-extensions.tamasfe.even-better-toml
            vscode-extensions.pkief.material-icon-theme
            vscode-extensions.jnoortheen.nix-ide
            vscode-extensions.ms-vscode-remote.remote-ssh
            vscode-extensions.ms-vscode-remote.remote-ssh-edit
            vscode-extensions.redhat.vscode-yaml
            # vscode-marketplace.continue.continue
            # vscode-marketplace.github.copilot
            # vscode-marketplace.github.copilot-chat
            vscode-extensions.continue.continue
            vscode-extensions.ms-python.python
            vscode-extensions.ms-python.vscode-pylance
          ] ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
            {
              name = "copilot";
              publisher = "github";
              version = "1.219.0";
              sha256 = "Y/l59JsmAKtENhBBf965brSwSkTjSOEuxc3tlWI88sY=";
            }
            {
              name = "copilot-chat";
              publisher = "github";
              version = "0.17.1";
              sha256 = "sha256-Aa4gmHJCveP18v6CAvmkxmqf1JV1LygyQFNpzDz64Gw=";
            }
          ];
      })
    ];
  };
}
