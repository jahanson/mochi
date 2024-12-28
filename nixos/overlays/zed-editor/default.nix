{ ... }:
let
  finalVersion = "0.149.3";
in
final: prev: {
  zed-editor = prev.zed-editor.overrideAttrs (oldAttrs: {
    version = finalVersion;
    src = prev.fetchFromGithub {
      hash = "sha256-ed6/QQObmclSA36g+civhii1aFKTBSjqB+LOyp2LUPg=";
    };
    cargoLock = prev.outputHashes {
      "blade-graphics-0.4.0" = "sha256-sGXhXmgtd7Wx/Gf7HCWro4RsQOGS4pQt8+S3T+2wMfY=";
    };
  });
}
