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
      x64-linux_hash = "sha256-qG/qV6qkfwA7eRfxW6+ysJ3YcrW2oAP9lYruK5yEORI=";
      arm64-linux_hash = lib.fakeSha256;
      x64-osx_hash = lib.fakeSha256;
      arm64-osx_hash = lib.fakeSha256;
    }
    ."${arch}-${os}_hash";
in
  stdenv.mkDerivation rec {
    pname = "sonarr";
    version = "4.0.13.2931";
    branch = "develop";

    src = fetchurl {
      # url = "https://github.com/Sonarr/Sonarr/releases/download/v${version}/Sonarr.main.${version}.${os}-${arch}.tar.gz";
      url = "https://services.sonarr.tv/v1/update/${branch}/download?version=${version}&os=${os}&runtime=netcore&arch=${arch}";
      sha256 = hash;
    };

    nativeBuildInputs = [makeWrapper];

    unpackPhase = ''
      mkdir -p $out
      tar -zxf $src --strip-components=1
    '';

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
