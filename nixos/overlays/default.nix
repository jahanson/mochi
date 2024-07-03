{ inputs, ... }:
let
  warpTerminalOverlay = import ./warp-terminal {
    inherit (inputs.nixpkgs) lib;
  };
  termiusOverlay = import ./termius { };
  talosctlOverlay = import ./talosctl { };
  goOverlay = import ./go { };
in
{
  nur = inputs.nur.overlay;
  warp-terminal = warpTerminalOverlay;
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
}
