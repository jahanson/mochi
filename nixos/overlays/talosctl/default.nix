{ ...}:
let
  finalVersion = "1.7.5";
in
(final: prev: {
  talosctl = prev.talosctl.overrideAttrs (oldAttrs: { 
    version = finalVersion;
    src = prev.fetchFromGitHub {
      owner = "siderolabs";
      repo = "talos";
      rev = "v${finalVersion}";
      hash = "sha256-lmDLlxiPyVhlSPplYkIaS5Uw19hir6XD8MAk8q+obhY=";
    };
    passthru = oldAttrs.passthru // {
      updateScript = ./update.sh;
    };
  });
})