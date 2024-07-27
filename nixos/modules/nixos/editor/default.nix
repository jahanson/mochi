{ lib, config, pkgs, ... }:
with lib;
let
  cfg = config.mySystem.editor.vscode;
  # VSCode Community Extensions. These are updated daily.
  vscodeCommunityExtensions = [
    "dracula-theme.theme-dracula"
    "esbenp.prettier-vscode"
    "jnoortheen.nix-ide"
    "mikestead.dotenv"
    "ms-azuretools.vscode-docker"
    # Python extensions *required* for redhat.ansible/vscode-yaml
    "ms-python.python"
    "ms-python.vscode-pylance"
    "ms-vscode-remote.remote-ssh"
    "ms-vscode-remote.remote-ssh-edit"
    "pkief.material-icon-theme"
    "redhat.ansible"
    "redhat.vscode-yaml"
    "signageos.signageos-vscode-sops"
    "tamasfe.even-better-toml"
    "tyriar.sort-lines"
    "yzhang.markdown-all-in-one"
    "mrmlnc.vscode-json5"
    "editorconfig.editorconfig"
  ];
  # Nixpkgs Extensions. These are updated whenver they get around to it.
  vscodeNixpkgsExtensions = [
    # Continue ships with a binary that requires the patchelf fix which is done by default in nixpkgs.
    "continue.continue"
  ];
  # Straight from the VSCode marketplace.
  marketplaceExtensions = [
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
      sha256 = "Aa4gmHJCveP18v6CAvmkxmqf1JV1LygyQFNpzDz64Gw=";
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
