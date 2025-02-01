{
  lib,
  config,
  pkgs,
  ...
}:
with lib; let
  cfg = config.mySystem.editor.vscode;
  # VSCode Community Extensions. These are updated daily.
  vscodeCommunityExtensions = [
    "bmalehorn.vscode-fish"
    "dracula-theme.theme-dracula"
    "catppuccin.catppuccin-vsc"
    "editorconfig.editorconfig"
    "esbenp.prettier-vscode"
    "foxundermoon.shell-format"
    # "github.copilot"
    "jnoortheen.nix-ide"
    "mikestead.dotenv"
    "mrmlnc.vscode-json5"
    # "ms-python.python" # Python extensions *required* for redhat.ansible/vscode-yaml
    "ms-python.vscode-pylance"
    "ms-vscode-remote.remote-ssh-edit"
    "pkief.material-icon-theme"
    "redhat.ansible"
    "redhat.vscode-yaml"
    "signageos.signageos-vscode-sops"
    "tamasfe.even-better-toml"
    "task.vscode-task"
    "tyriar.sort-lines"
    "yzhang.markdown-all-in-one"
    "fill-labs.dependi"
    "rust-lang.rust-analyzer"
    "dustypomerleau.rust-syntax"
    "exiasr.hadolint"
    # "github.copilot-chat"
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
      version = "1.261.0";
      sha256 = "sha256-8IElcnSmngget8gduhdJUMx++PslOg58zcLwhRZCNyk=";
    }
    {
      # Apparently there's no insiders build for copilot-chat so the latest isn't what we want.
      # The latest generally targets insiders build of vs code right now and it won't load on stable.
      name = "copilot-chat";
      publisher = "github";
      version = "0.23.2";
      sha256 = "sha256-OT+ynCA+z8TvDE02hkOEQcJ1mBNz6geLxLOFtgIgKZE=";
    }
    {
      # Same issue as the above -- auto pulling nightly builds not compatible with vscode stable.
      name = "python";
      publisher = "ms-python";
      version = "2024.22.2";
      sha256 = "sha256-uVv4kpTf0W82Gvoju0Q/HKf6SpN2mwuYO7NItlRoezI=";
    }
  ];
  # Extract extension strings and coerce them to a list of valid attribute paths.
  vscodeCommunityExtensionsPackages =
    map (
      ext: getAttrFromPath (splitString "." ext) pkgs.vscode-marketplace
    )
    vscodeCommunityExtensions;
  nixpkgsExtensionsPackages =
    map (
      ext: getAttrFromPath (splitString "." ext) pkgs.vscode-extensions
    )
    vscodeNixpkgsExtensions;
  marketplaceExtensionsPackages = pkgs.vscode-utils.extensionsFromVscodeMarketplace marketplaceExtensions;
in {
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
