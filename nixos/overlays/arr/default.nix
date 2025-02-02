{pkgs}: let
  getPackages = dir: pkgs.lib.mapAttrs (name: _: pkgs.callPackage (dir + "/${name}") {}) (builtins.readDir dir);
in
  getPackages ./.
