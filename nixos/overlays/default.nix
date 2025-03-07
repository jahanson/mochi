{inputs, ...}: let
  # smartmontoolsOverlay = import ./smartmontools { };
  # vivaldiOverlay = self: super: { vivaldi = super.callPackage ./vivaldi { }; };
  coderOverlay = self: super: {coder = super.callPackage ./coder {};};
  # modsOverlay = self: super: { mods = super.callPackage ./charm-mods { }; };
  termiusOverlay = self: super: {termius = super.callPackage ./termius {};};
in {
  # smartmontools = smartmontoolsOverlay;
  # vivaldi = vivaldiOverlay;
  coder = coderOverlay;
  comm-packages = inputs.nix-vscode-extensions.overlays.default;
  # mods = modsOverlay;
  nix-minecraft = inputs.nix-minecraft.overlay;
  nur = inputs.nur.overlays.default;
  termius = termiusOverlay;

  # The unstable nixpkgs set (declared in the flake inputs) will
  # be accessible through 'pkgs.unstable'
  unstable-packages = final: prev: {
    unstable =
      import inputs.nixpkgs-unstable {
        inherit (final) system;
        config.allowUnfree = true;
      }
      // {
        # Add talosctl to the unstable set
        talosctl = final.unstable.callPackage ./talosctl {
          inherit
            (final.unstable)
            lib
            buildGoModule
            fetchFromGitHub
            installShellFiles
            ;
        };
        xpipe = final.unstable.callPackage ./xpipe/ptb.nix {};
        prowlarr = final.unstable.callPackage ./arr/prowlarr.nix {};
        radarr = final.unstable.callPackage ./arr/radarr.nix {};
        sonarr = final.unstable.callPackage ./arr/sonarr.nix {};
      };
  };

  master-packages = final: prev: {
    master = import inputs.nixpkgs-master {
      inherit (final) system;
      config.allowUnfree = true;
    };
  };
}
