{ lib, ... }:
let
  dir = ./.;
  files = lib.filterAttrs (name: type:
    type == "regular" && name != "default.nix" && lib.hasSuffix ".nix" name
  ) (builtins.readDir dir);
  imports = map (name: "${dir}/${name}") (builtins.attrNames files);
in {
  imports = imports;
}
