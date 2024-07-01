{ lib, ...}:
let 
  versions = lib.importJSON ./versions.json;
in
(final: prev: {
  warp-terminal = prev.warp-terminal.overrideAttrs (oldAttrs: { 
    version = versions.linux.version;
    src = prev.fetchurl {
      url = "https://releases.warp.dev/stable/v${versions.linux.version}/warp-terminal-v${versions.linux.version}-1-x86_64.pkg.tar.zst";
      hash = versions.linux.hash;
    };
    # postInstall = ''
    #   install -Dm644 $out/share/icons/hicolor/128x128/apps/dev.warp.Warp.png $out/share/icons/hicolor/128x128/apps/org.wezfurlong.wezterm.png
    # '';
  });
})