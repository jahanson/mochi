{ ... }:
let
  finalVersion = "1.22.4";
in
(final: prev: {
  go = prev.go.overrideAttrs (oldAttrs: { 
    version = finalVersion;
    src = prev.fetchurl {
      url = "https://go.dev/dl/go${finalVersion}.src.tar.gz";
      hash = "sha256-/tcgZ45yinyjC6jR3tHKr+J9FgKPqwIyuLqOIgCPt4Q=";
    };
  });
})