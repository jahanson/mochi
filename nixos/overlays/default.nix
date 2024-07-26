{ inputs, ... }:
let
  warpTerminalOverlay = import ./warp-terminal {
    inherit (inputs.nixpkgs) lib;
  };
  termiusOverlay = import ./termius { };
  # Partial overlay
  # talosctlOverlay = import ./talosctl { };
  # Full overlay
  talosctlOverlay = self: super: {
    talosctl = super.callPackage ./talosctl/talosctl-custom.nix { };
  };
  goOverlay = import ./go { };
in
{
  nur = inputs.nur.overlay;
  # warp-terminal = warpTerminalOverlay;
  termius = termiusOverlay;
  talosctl = talosctlOverlay;
  # go = goOverlay;

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
