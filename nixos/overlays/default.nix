{ inputs, ... }:
let
  inherit (inputs.nixpkgs) lib;

  vivaldiOverlay = self: super: {
    vivaldi = super.callPackage ./vivaldi { };
  };

  termiusOverlay = self: super: {
    termius = super.callPackage ./termius { };
  };
  modsOverlay = self: super: {
    mods = super.callPackage ./charm-mods { };
  };
in
{
  nur = inputs.nur.overlay;
  vivaldi = vivaldiOverlay;
  termius = termiusOverlay;
  mods = modsOverlay;

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
