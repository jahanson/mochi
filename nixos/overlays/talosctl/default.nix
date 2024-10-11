{ ... }:
let
  finalVersion = "1.8.1";
in
final: prev: {
  talosctl = prev.talosctl.overrideAttrs (oldAttrs: {
    version = finalVersion;
    src = prev.fetchFromGitHub {
      owner = "siderolabs";
      repo = "talos";
      rev = "v${finalVersion}";
      hash = "sha256-6WHeiVH/vZHiM4bqq3T5lC0ARldJyZtIErPeDgrZgxc=";
    };
    vendorHash = "sha256-aTtvVpL979BUvSBwBqRqCWSWIBBmmty9vBD97Q5P4+E=";
  });
}
