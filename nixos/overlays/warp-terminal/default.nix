{ lib, ...}:
let 
  versions = lib.importJSON ./versions.json;
in
final: prev: {
  warp-terminal = prev.warp-terminal.overrideAttrs (oldAttrs: { 
    inherit (versions.linux) version;
    src = prev.fetchurl {
      url = "https://releases.warp.dev/stable/v${versions.linux.version}/warp-terminal-v${versions.linux.version}-1-x86_64.pkg.tar.zst";
      inherit (versions.linux) hash;
    };
  });
}