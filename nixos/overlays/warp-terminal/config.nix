{ lib, ... }:
let
  versions = lib.importJSON ./versions.json;
in
{
  packageOverrides = pkgs: {
    warp-terminal = pkgs.warp-terminal.override {
      version = "0.2024.06.25.08.02.stable_01";
      src = lib.fetchurl {
        hash = "sha256-Fc48bZzFBw9p636Mr8R+W/d1B3kIcOAu/Gd17nbzNfI=";
        url = "https://releases.warp.dev/stable/v0.2024.06.25.08.02.stable_01/warp-terminal-v0.2024.06.25.08.02.stable_01-1-x86_64.pkg.tar.zst";
      };
    };
  };
}
