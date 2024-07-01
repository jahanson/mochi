{ inputs, ... }:
let
  warpTerminal = import ./warp-terminal/warp-terminal.nix {
    inherit (inputs.nixpkgs) lib;
  };
in
{
  nur = inputs.nur.overlay;
  warp-terminal = warpTerminal;

  # The unstable nixpkgs set (declared in the flake inputs) will
  # be accessible through 'pkgs.unstable'
  # great idea if I wasn't using unstable as my base.
  # unstable-packages = final: _prev: {
  #   unstable = import inputs.nixpkgs-unstable {
  #     inherit (final) system;
  #     config.allowUnfree = true;
  #   };
  # };
}
