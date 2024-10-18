{ ... }:
let
  finalVersion = "tauri-v2.0.4";
in
final: prev: {
  cargo-tauri = prev.cargo-tauri.overrideAttrs (oldAttrs: {
    version = finalVersion;
    vendorHash = "sha256-aTtvVpL979BUvSBwBqRqCWSWIBBmmty9vBD97Q5P4+E=";
  });
}
