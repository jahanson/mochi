{ lib, config, pkgs, ... }:
with lib;
let
  cfg = config.mySystem.hardware.nvidia;
in
{
  options.mySystem.hardware.nvidia.enable = mkEnableOption "NVIDIA config";

  config = mkIf cfg.enable {

    environment.sessionVariables.NIXOS_OZONE_WL = "1";
    # ref: https://nixos.wiki/wiki/Nvidia
    # Enable OpenGL
    hardware = {
      opengl = {
        enable = true;
        driSupport = true;
        driSupport32Bit = true;
      };

      hardware.opengl.extraPackages = with pkgs; [
        vaapiVdpau
      ];

      # This is for the benefit of VSCODE running natively in wayland

      hardware.nvidia = {

        # Modesetting is required.
        modesetting.enable = true;

        # Nvidia power management. Experimental, and can cause sleep/suspend to fail.
        # Enable this if you have graphical corruption issues or application crashes after waking
        # up from sleep. This fixes it by saving the entire VRAM memory to /tmp/ instead
        # of just the bare essentials.
        powerManagement.enable = false;

        # Fine-grained power management. Turns off GPU when not in use.
        # Experimental and only works on modern Nvidia GPUs (Turing or newer).
        powerManagement.finegrained = false;

        # Use the NVidia open source kernel module (not to be confused with the
        # independent third-party "nouveau" open source driver).
        # Support is limited to the Turing and later architectures. Full list of
        # supported GPUs is at:
        # https://github.com/NVIDIA/open-gpu-kernel-modules#compatible-gpus
        # Only available from driver 515.43.04+
        # Currently alpha-quality/buggy, so false is currently the recommended setting.
        open = false;

        # Enable the Nvidia settings menu,
        # accessible via `nvidia-settings`.
        nvidiaSettings = true;

        # Optionally, you may need to select the appropriate driver version for your specific GPU.
        # package = config.boot.kernelPackages.nvidiaPackages.stable;

        # manual build nvidia driver, works around some wezterm issues
        # https://github.com/wez/wezterm/issues/2011
        package =
          # let
          # rcu_patch = pkgs.fetchpatch {
          #   url = "https://github.com/gentoo/gentoo/raw/c64caf53/x11-drivers/nvidia-drivers/files/nvidia-drivers-470.223.02-gpl-pfn_valid.patch";
          #   hash = "sha256-eZiQQp2S/asE7MfGvfe6dA/kdCvek9SYa/FFGp24dVg=";
          # };
          # in
          config.boot.kernelPackages.nvidiaPackages.mkDriver {
            version = "555.58";
            sha256_64bit = "sha256-bXvcXkg2kQZuCNKRZM5QoTaTjF4l2TtrsKUvyicj5ew=";
            sha256_aarch64 = "sha256-7XswQwW1iFP4ji5mbRQ6PVEhD4SGWpjUJe1o8zoXYRE=";
            openSha256 = "sha256-hEAmFISMuXm8tbsrB+WiUcEFuSGRNZ37aKWvf0WJ2/c=";
            settingsSha256 = "sha256-vWnrXlBCb3K5uVkDFmJDVq51wrCoqgPF03lSjZOuU8M=";
            persistencedSha256 = "sha256-lyYxDuGDTMdGxX3CaiWUh1IQuQlkI2hPEs5LI20vEVw=";
            # patches = [ rcu_patch ];
          };
      };
    };

    nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  };
}
