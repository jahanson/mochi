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
}: let
  os =
    if stdenv.hostPlatform.isDarwin
    then "osx"
    else "linux";
  arch =
    {
      x86_64-linux = "x64";
      aarch64-linux = "arm64";
      x86_64-darwin = "x64";
      aarch64-darwin = "arm64";
    }
    ."${stdenv.hostPlatform.system}"
    or (throw "Unsupported system: ${stdenv.hostPlatform.system}");

  hash =
    {
      x64-linux_hash = "sha256-D0Np9Jz7E4/1dnWkFdHQIGthklCVc6yav2AAE9pFcu0=";
      arm64-linux_hash = lib.fakeSha256;
      x64-osx_hash = lib.fakeSha256;
      arm64-osx_hash = lib.fakeSha256;
    }
    ."${arch}-${os}_hash";
in
  stdenv.mkDerivation rec {
    pname = "radarr";
    version = "5.18.4.9674";

    src = fetchurl {
      url = "https://github.com/Radarr/Radarr/releases/download/v${version}/Radarr.master.${version}.${os}-core-${arch}.tar.gz";
      sha256 = hash;
    };

    nativeBuildInputs = [makeWrapper];

    installPhase = ''
      runHook preInstall

      mkdir -p $out/{bin,share/${pname}-${version}}
      cp -r * $out/share/${pname}-${version}/.

      makeWrapper "${dotnet-runtime}/bin/dotnet" $out/bin/Radarr \
        --add-flags "$out/share/${pname}-${version}/Radarr.dll" \
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
      updateScript = ./update.sh;
      tests.smoke-test = nixosTests.radarr;
    };

    meta.mainProgram = "Radarr";
  }
