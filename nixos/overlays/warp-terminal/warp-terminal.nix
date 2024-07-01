{ lib, ...}:
let 
  versions = lib.importJSON ./versions.json;
in
(final: prev: {
  warp-terminal = prev.warp-terminal.overrideAttrs (oldAttrs: { 
    version = versions.linux.version;
    src = builtins.fetchurl {
      url = "https://releases.warp.dev/stable/v${versions.linux.version}/warp-terminal-v${versions.linux.version}-1-x86_64.pkg.tar.zst";
      sha256 = versions.linux.hash;
    };
  });
})