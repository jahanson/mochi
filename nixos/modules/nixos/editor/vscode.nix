{ lib, config, pkgs, ... }:
with lib;
let
  cfg = config.mySystem.editor.vscode;
  # VSCode Community Extensions. These are updated daily.
  vscodeCommunityExtensions = [
    "dracula-theme.theme-dracula"
    "editorconfig.editorconfig"
    "esbenp.prettier-vscode"
    "github.copilot"
    # "github.copilot-chat"
    "jnoortheen.nix-ide"
    "mikestead.dotenv"
    "mrmlnc.vscode-json5"
    "ms-azuretools.vscode-docker"
    # Python extensions *required* for redhat.ansible/vscode-yaml
    "ms-python.python"
    "ms-python.vscode-pylance"
    "pkief.material-icon-theme"
    "redhat.ansible"
    "redhat.vscode-yaml"
    "signageos.signageos-vscode-sops"
    "tamasfe.even-better-toml"
    "tyriar.sort-lines"
    "yzhang.markdown-all-in-one"
    "foxundermoon.shell-format"
    "ahmadalli.vscode-nginx-conf"
  ];
  # Nixpkgs Extensions. These are updated whenver they get around to it.
  vscodeNixpkgsExtensions = [
    # Continue ships with a binary that requires the patchelf fix which is done by default in nixpkgs.
    "continue.continue"
    "ms-vscode-remote.remote-ssh"
    "ms-vscode-remote.remote-ssh-edit"
  ];
  # Straight from the VSCode marketplace.
  marketplaceExtensions = [
    # {
    #   name = "copilot";
    #   publisher = "github";
    #   version = "1.219.0";
    #   sha256 = "Y/l59JsmAKtENhBBf965brSwSkTjSOEuxc3tlWI88sY=";
    # }
    { # Apparently there's no insiders build for copilot-chat so the latest isn't what we want.
      # The latest generally targets insiders build of vs code right now and it won't load on stable.
      name = "copilot-chat";
      publisher = "github";
      version = "0.18.2";
      sha256 = "sha256-cku6FV88jMwWoxSiMAufZy00H9Wc1XnJJDBrfWAwXPg=";
    }
  ];
  # Extract extension strings and coerce them to a list of valid attribute paths.
  vscodeCommunityExtensionsPackages = map (ext: getAttrFromPath (splitString "." ext) pkgs.vscode-marketplace) vscodeCommunityExtensions;
  nixpkgsExtensionsPackages = map (ext: getAttrFromPath (splitString "." ext) pkgs.vscode-extensions) vscodeNixpkgsExtensions;
  marketplaceExtensionsPackages = pkgs.vscode-utils.extensionsFromVscodeMarketplace marketplaceExtensions;
in
{
  options.mySystem.editor.vscode.enable = mkEnableOption "vscode";
  config = mkIf cfg.enable {

    # Enable vscode & addons
    environment.systemPackages = with pkgs; [
      (vscode-with-extensions.override {
        inherit (unstable) vscode;
        # Merge all the extension packages together.
        vscodeExtensions =
          vscodeCommunityExtensionsPackages ++ nixpkgsExtensionsPackages ++ marketplaceExtensionsPackages;
      })
    ];
  };
}
