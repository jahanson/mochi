{ ... }:
let
  finalVersion = "1.22.5";
in
(final: prev: {
  go_1_22 = prev.go_1_22.overrideAttrs (oldAttrs: { 
    version = finalVersion;
    src = prev.fetchurl {
      url = "https://go.dev/dl/go${finalVersion}.src.tar.gz";
      hash = "sha256-rJxyPyJJaa7mJLw0/TTJ4T8qIS11xxyAfeZEu0bhEvY=";
    };
  });
})