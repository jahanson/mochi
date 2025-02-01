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
      x64-linux_hash = "sha256-aiH4bv47cnBzUtFwfJfmrY+2LaqgZkRXT2Jx8FkSX7M=";
      arm64-linux_hash = lib.fakeSha256;
      x64-osx_hash = lib.fakeSha256;
      arm64-osx_hash = lib.fakeSha256;
    }
    ."${arch}-${os}_hash";
in
  stdenv.mkDerivation rec {
    pname = "prowlarr";
    version = "1.30.2.4939";

    src = fetchurl {
      url = "https://github.com/Prowlarr/Prowlarr/releases/download/v${version}/Prowlarr.master.${version}.${os}-core-${arch}.tar.gz";
      sha256 = hash;
    };

    nativeBuildInputs = [makeWrapper];

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
