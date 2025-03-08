{
  pkgs,
  myPkgs,
  inputs,
  ...
}:
# Role for dev stations
# Could be a workstation or a headless server.
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
      alejandra

      # dev
      uv # python package manager
      bash-language-server
      fd
      gh
      go
      hadolint
      kubectl
      minio-client # S3 management
      nodejs_22
      pre-commit # Pre-commit tasks for git
      shellcheck # shell script linting
      shfmt
      statix
      tmux
      yt-dlp
      #unstable.aider-chat
      unstable.bottom
      unstable.cyme
      unstable.go-task
      unstable.helix
      unstable.sops
      unstable.talosctl # overlay override
      unstable.zellij
      unstable.kitty
      unstable.nodePackages_latest.prettier # code formatter
      unstable.aider-chat

      # flake imports
      inputs.nix-inspect.packages.${pkgs.system}.default
      inputs.talhelper.packages.${pkgs.system}.default

      # charmbracelet tools
      myPkgs.mods
      gum
      skate
      unstable.glow
      vhs
      unstable.soft-serve

      # VMs
      ## Distrobox
      distrobox
      distrobox-tui
      boxbuddy
    ];

    programs = {
      mtr.enable = true;
      direnv = {
        # TODO move to home-manager
        enable = true;
        nix-direnv.enable = true;
      };
    };
  };
}
