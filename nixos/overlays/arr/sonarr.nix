{
  lib,
  stdenv,
  fetchurl,
  mono,
  libmediainfo,
  sqlite,
  curl,
  makeWrapper,
  icu,
  dotnet-runtime,
  openssl,
  nixosTests,
  zlib,
}:
let
  os = if stdenv.hostPlatform.isDarwin then "osx" else "linux";
  arch =
    {
      x86_64-linux = "x64";
      aarch64-linux = "arm64";
      x86_64-darwin = "x64";
      aarch64-darwin = "arm64";
    }
    ."${stdenv.hostPlatform.system}" or (throw "Unsupported system: ${stdenv.hostPlatform.system}");

  hash =
    {
      x64-linux_hash = "sha256-/vsU0M8jyyfYVpE75gSa7R6aSyhxBg8gO3c+G3qCA+E=";
      arm64-linux_hash = lib.fakeSha256;
      x64-osx_hash = lib.fakeSha256;
      arm64-osx_hash = lib.fakeSha256;
    }
    ."${arch}-${os}_hash";
in
stdenv.mkDerivation rec {
  pname = "sonarr";
  version = "4.0.12.2823";

  src = fetchurl {
    url = "https://github.com/Sonarr/Sonarr/releases/download/v${version}/Sonarr.main.${version}.${os}-${arch}.tar.gz";
    sha256 = hash;
  };

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/{bin,share/${pname}-${version}}
    cp -r * $out/share/${pname}-${version}/.

    makeWrapper "${dotnet-runtime}/bin/dotnet" $out/bin/Sonarr \
      --add-flags "$out/share/${pname}-${version}/Sonarr.dll" \
      --prefix LD_LIBRARY_PATH : ${
        lib.makeLibraryPath [
          curl
          sqlite
          libmediainfo
          mono
          openssl
          icu
          zlib
        ]
      }

    runHook postInstall
  '';
  passthru = {
    tests.smoke-test = nixosTests.radarr;
  };

  meta.mainProgram = "Sonarr";
}
