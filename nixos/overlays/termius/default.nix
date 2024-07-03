{ ... }:
(final: prev: {
  termius = prev.termius.overrideAttrs (oldAttrs: {
    postInstall = ''
      install -Dm644 meta/gui/icon.png $out/share/icons/hicolor/128x128/apps/termius-app.png
    '';
  });
})
