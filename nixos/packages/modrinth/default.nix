{
  atk,
  bzip2,
  cacert,
  cairo,
  cargo-tauri,
  darwin,
  dbus,
  desktop-file-utils,
  fetchFromGitHub,
  gdk-pixbuf,
  glib,
  gtk3,
  lib,
  libsoup_3,
  nodejs,
  openssl,
  pango,
  pkg-config,
  pnpm_9,
  rust-jemalloc-sys,
  rustPlatform,
  sqlite,
  stdenv,
  turbo,
  wayland,
  webkitgtk_4_1,
  wrapGAppsHook,
  xz,
  zstd,
}: let
  pnpm = pnpm_9;
  webkitgtk = webkitgtk_4_1;
in
  rustPlatform.buildRustPackage rec {
    pname = "modrinth-app";
    version = "0.9.3";

    src = fetchFromGitHub {
      owner = "modrinth";
      repo = "code";
      rev = "v${version}";
      hash = "sha256-h+zj4Hm7v8SU6Zy0rIWbOknXVdSDf8b1d4q6M12J5Lc=";
    };

    cargoLock = {
      lockFile = ./Cargo.lock;
      outputHashes = {
        "wry-0.47.2" = "sha256-zb/BX2UU3Hw87H0m+l3wl6YnCroC+93xMMr+SGl532w=";
      };
    };

    pnpmDeps = pnpm.fetchDeps {
      inherit pname version src;
      hash = "sha256-nFuPFgwJw38XVxhW0QXmU31o+hqJKGJysnPg2YSg2D0=";
    };

    nativeBuildInputs = [
      pkg-config
      wrapGAppsHook
      cacert # Required for turbo
      cargo-tauri.hook
      desktop-file-utils
      nodejs
      pnpm.configHook
    ];

    buildInputs =
      [
        atk
        bzip2
        cairo
        dbus
        gdk-pixbuf
        glib
        gtk3
        libsoup_3
        openssl
        pango
        rust-jemalloc-sys
        sqlite
        webkitgtk
        xz
        zstd
      ]
      ++ lib.optionals stdenv.isDarwin [
        darwin.apple_sdk.frameworks.AppKit
        darwin.apple_sdk.frameworks.CoreFoundation
        darwin.apple_sdk.frameworks.CoreGraphics
        darwin.apple_sdk.frameworks.CoreServices
        darwin.apple_sdk.frameworks.Foundation
        darwin.apple_sdk.frameworks.IOKit
        darwin.apple_sdk.frameworks.Security
        darwin.apple_sdk.frameworks.SystemConfiguration
      ]
      ++ lib.optionals stdenv.isLinux [
        wayland
        webkitgtk_4_1
      ];

    # Tests fail on other, unrelated packages in the monorepo
    cargoTestFlags = [
      "--package"
      "theseus_gui"
    ];

    env = {
      # OPENSSL_NO_VENDOR = true;
      # ZSTD_SYS_USE_PKG_CONFIG = true;
      TURBO_BINARY_PATH = lib.getExe turbo;
    };

    meta = {
      description = "The Modrinth monorepo containing all code which powers Modrinth";
      homepage = "https://github.com/modrinth/code";
      license = with lib.licenses; [
        gpl3Plus
        unfreeRedistributable
      ];
      maintainers = with lib.maintainers; [];
      mainProgram = "modrinth-app";
    };
  }
