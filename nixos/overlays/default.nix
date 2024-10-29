{ inputs, ... }:
let
  # smartmontoolsOverlay = import ./smartmontools { };
  # vivaldiOverlay = self: super: { vivaldi = super.callPackage ./vivaldi { }; };
  coderOverlay = self: super: { coder = super.callPackage ./coder { }; };
  modsOverlay = self: super: { mods = super.callPackage ./charms-mods { }; };
  termiusOverlay = self: super: { termius = super.callPackage ./termius { }; };
in
{
  # smartmontools = smartmontoolsOverlay;
  # vivaldi = vivaldiOverlay;
  coder = coderOverlay;
  comm-packages = inputs.nix-vscode-extensions.overlays.default;
  mods = modsOverlay;
  nix-minecraft = inputs.nix-minecraft.overlay;
  nur = inputs.nur.overlay;
  termius = termiusOverlay;

  # The unstable nixpkgs set (declared in the flake inputs) will
  # be accessible through 'pkgs.unstable'
  unstable-packages = final: prev: {
    unstable = import inputs.nixpkgs-unstable
      {
        inherit (final) system;
        config.allowUnfree = true;
      } // {
      # Add talosctl to the unstable set
      talosctl = final.unstable.callPackage ./talosctl {
        inherit (final.unstable) lib buildGoModule fetchFromGitHub installShellFiles;
      };
    };
  };
}
