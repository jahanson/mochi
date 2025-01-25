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
      hwinfo
      unstable.k9s

      # nix lsp/formatters
      nil
      nixd
      nixpkgs-fmt
      unstable.nixfmt-rfc-style # nixfmt RFC 166-style compatible with nixpkgs soon

      # dev
      bash-language-server
      fd
      gh
      go
      hadolint
      kubectl
      minio-client # S3 management
      pre-commit # Pre-commit tasks for git
      shellcheck # shell script linting
      shfmt
      statix
      tmux
      unstable.bottom
      unstable.cyme
      unstable.go-task
      unstable.helix
      unstable.sops
      unstable.talosctl # overlay override
      unstable.zellij

      # flake imports
      inputs.nix-inspect.packages.${pkgs.system}.default
      inputs.talhelper.packages.${pkgs.system}.default

      # charmbracelet tools
      gum
      mods
      skate
      soft-serve
      unstable.glow
      vhs
    ];

    programs.direnv = {
      # TODO move to home-manager
      enable = true;
      nix-direnv.enable = true;
    };
  };
}
