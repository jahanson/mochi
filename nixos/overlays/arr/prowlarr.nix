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
      x64-linux_hash = "sha256-P2VEFDWOj4RawORH35Hxh59Aine3gp3WpTDxmzzmJGg=";
      arm64-linux_hash = lib.fakeSha256;
      x64-osx_hash = lib.fakeSha256;
      arm64-osx_hash = lib.fakeSha256;
    }
    ."${arch}-${os}_hash";
in
  stdenv.mkDerivation rec {
    pname = "prowlarr";
    version = "1.31.1.4959";
    branch = "develop";

    src = fetchurl {
      name = "prowlarr-v${version}";
      # url = "https://github.com/Prowlarr/Prowlarr/releases/download/v${version}/Prowlarr.master.${version}.${os}-core-${arch}.tar.gz";
      # url = "https://prowlarr.servarr.com/v1/update/develop/updatefile?version=1.31.1.4959&os=linux&runtime=netcore&arch=x64";
      url = "https://prowlarr.servarr.com/v1/update/${branch}/updatefile?version=${version}&os=linux&runtime=netcore&arch=${arch}";
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

      makeWrapper "${dotnet-runtime}/bin/dotnet" $out/bin/Prowlarr \
        --add-flags "$out/share/${pname}-${version}/Prowlarr.dll" \
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

    meta.mainProgram = "Prowlarr";
  }
