{
  pkgs,
  inputs,
  ...
}:
# Role for dev stations
# Could be a workstatio or a headless server.

{
  config = {
    # git & vim are in global
    environment.systemPackages = with pkgs; [
      btop
      dnsutils
      fira-code-nerdfont
      jo
      jq
      nix
      unstable.ncdu
      yq-go

      # nix lsp/formatters
      nil
      nixd
      nixpkgs-fmt
      unstable.nixfmt-rfc-style # nixfmt RFC 166-style compatible with nixpkgs soon

      # dev
      gh
      go
      hadolint
      shfmt
      statix
      tmux
      unstable.cyme
      unstable.go-task
      unstable.helix

      # flake imports
      inputs.nix-inspect.packages.${pkgs.system}.default
      inputs.talhelper.packages.${pkgs.system}.default

      # charmbracelet tools
      gum
      unstable.glow
      vhs
      mods
      soft-serve
    ];

    programs.direnv = {
      # TODO move to home-manager
      enable = true;
      nix-direnv.enable = true;
    };
  };
}
