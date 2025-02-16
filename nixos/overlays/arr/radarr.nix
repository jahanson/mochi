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
      x64-linux_hash = "sha256-JE6zUCUqC0MaAZ8gVfYV54q7M4eXVhxvx2Q9FzQfHVw=";
      arm64-linux_hash = lib.fakeSha256;
      x64-osx_hash = lib.fakeSha256;
      arm64-osx_hash = lib.fakeSha256;
    }
    ."${arch}-${os}_hash";
in
  stdenv.mkDerivation rec {
    pname = "radarr";
    version = "5.19.0.9697";
    branch = "develop";

    src = fetchurl {
      # url = "https://github.com/Radarr/Radarr/releases/download/v${version}/Radarr.master.${version}.${os}-core-${arch}.tar.gz";
      url = "https://radarr.servarr.com/v1/update/${branch}/updatefile?version=${version}&os=linux&runtime=netcore&arch=${arch}";
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
      tests.smoke-test = nixosTests.radarr;
    };

    meta.mainProgram = "Radarr";
  }
