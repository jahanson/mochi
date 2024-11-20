# Need the unstable nixpkgs to get latest dev tools
let
  nixpkgs = fetchTarball "https://github.com/NixOS/nixpkgs/archive/nixos-unstable.tar.gz";
  pkgs = import nixpkgs { allowUnfree = true; };
in
pkgs.mkShell {
  # Enable experimental features without having to specify the argument
  NIX_CONFIG = "experimental-features = nix-command flakes";
  shellHook = ''
    export TMP=$(mktemp -d "/tmp/nix-shell-XXXXXX")
    export TEMP=$TMP
    export TMPDIR=$TMP
  '';

  nativeBuildInputs = with pkgs; [
    cachix
    git
    gitleaks
    go-task
    pre-commit
    sops
    statix
  ];
}
