{ inputs, ... }:
let
  inherit (inputs.nixpkgs) lib;
  termiusOverlay = import ./termius { };
  talosctlOverlay = self: super: {
    talosctl = super.callPackage ./talosctl/talosctl-custom.nix { };
  };

  # Wasteland of old overlays
  # warpTerminalOverlay = import ./warp-terminal {};
  # goOverlay = import ./go { };
  # zedEditorOverlay = import ./zed-editor { };
in
{
  nur = inputs.nur.overlay;
  # termius = termiusOverlay;
  # talosctl = talosctlOverlay;

  # Wasteland of old overlays
  # warp-terminal = warpTerminalOverlay;
  # go = goOverlay;
  # zed-editor = zedEditorOverlay;

  # The unstable nixpkgs set (declared in the flake inputs) will
  # be accessible through 'pkgs.unstable'
  unstable-packages = final: _prev: {
    unstable = import inputs.nixpkgs-unstable {
      inherit (final) system;
      config.allowUnfree = true;
    };
  };

  # VSCode Community Packages
  comm-packages = inputs.nix-vscode-extensions.overlays.default;
}
