# Shell for bootstrapping flake-enabled nix and home-manager
{ pkgs ? import <nixpkgs> {} }:
pkgs.mkShell {
  # Enable experimental features without having to specify the argument
  NIX_CONFIG = "experimental-features = nix-command flakes";

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
