{
  autoPatchelfHook,
  squashfsTools,
  alsa-lib,
  fetchurl,
  makeDesktopItem,
  makeWrapper,
  stdenv,
  lib,
  libsecret,
  mesa,
  udev,
  wrapGAppsHook3,
}:
stdenv.mkDerivation rec {
  pname = "termius";
  version = "9.5.0";

  src = fetchurl {
    # find the latest version with
    # curl -H 'X-Ubuntu-Series: 16' https://api.snapcraft.io/api/v1/snaps/details/termius-app | jq '.version'
    # and the url with
    # curl -H 'X-Ubuntu-Series: 16' https://api.snapcraft.io/api/v1/snaps/details/termius-app | jq '.download_url' -r
    # and the sha512 with
    # curl -H 'X-Ubuntu-Series: 16' https://api.snapcraft.io/api/v1/snaps/details/termius-app | jq '.download_sha512' -r
    # nix-hash --type sha512 --to-sri <output of curl>
    url = "https://api.snapcraft.io/api/v1/snaps/download/WkTBXwoX81rBe3s3OTt3EiiLKBx2QhuS_203.snap";
    hash = "sha512-BouIQvJZbi350l30gl9fnXKYRHhi5q1oOvyEIVEmd4DjXvJLQisV4cK4OZIJ/bPOCI5DTxNOY7PwEduVQd3SYA==";
    #
  };

  desktopItem = makeDesktopItem {
    categories = ["Network"];
    comment = "The SSH client that works on Desktop and Mobile";
    desktopName = "Termius";
    exec = "termius-app";
    genericName = "Cross-platform SSH client";
    icon = "termius-app";
    name = "termius-app";
  };

  dontBuild = true;
  dontConfigure = true;
  dontPatchELF = true;
  dontWrapGApps = true;

  # TODO: migrate off autoPatchelfHook and use nixpkgs' electron
  nativeBuildInputs = [
    autoPatchelfHook
    squashfsTools
    makeWrapper
    wrapGAppsHook3
  ];

  buildInputs = [
    alsa-lib
    libsecret
    mesa
  ];

  unpackPhase = ''
    runHook preUnpack
    unsquashfs "$src"
    runHook postUnpack
  '';

  installPhase = ''
    runHook preInstall
    cd squashfs-root
    mkdir -p $out/opt/termius
    cp -r ./ $out/opt/termius

    mkdir -p "$out/share/applications" "$out/share/pixmaps/termius-app.png"
    cp "${desktopItem}/share/applications/"* "$out/share/applications"
    cp meta/gui/icon.png $out/share/pixmaps/termius-app.png

    runHook postInstall
  '';

  postInstall = ''
    install -Dm644 meta/gui/icon.png $out/share/icons/hicolor/128x128/apps/termius-app.png
  '';

  runtimeDependencies = [(lib.getLib udev)];

  postFixup = ''
    makeWrapper $out/opt/termius/termius-app $out/bin/termius-app \
      "''${gappsWrapperArgs[@]}"
  '';

  meta = with lib; {
    description = "A cross-platform SSH client with cloud data sync and more";
    homepage = "https://termius.com/";
    downloadPage = "https://termius.com/linux/";
    sourceProvenance = with sourceTypes; [binaryNativeCode];
    license = licenses.unfree;
    maintainers = with maintainers; [
      Br1ght0ne
      th0rgal
    ];
    platforms = ["x86_64-linux"];
    mainProgram = "termius-app";
  };
}
