{
  description = "My NixOS flake";

  inputs = {
    # Nixpkgs and unstable
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    # Lix - Substitution of the Nix package manager, focused on correctness, usability, and growth – and committed to doing right by its community.
    # https://git.lix.systems/lix-project/lix
    lix-module = {
      url = "https://git.lix.systems/lix-project/nixos-module/archive/2.92.0.tar.gz";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Nix User Repository: User contributed nix packages
    nur.url = "github:nix-community/NUR";

    # nix-community hardware quirks
    # https://github.com/nix-community
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    # disko - Declarative disk partitioning and formatting using nix
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # home-manager - Manage user configuration with nix
    # https://github.com/nix-community/home-manager
    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # sops-nix - secrets with mozilla sops
    # https://github.com/Mic92/sops-nix
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # VSCode community extensions
    # https://github.com/nix-community/nix-vscode-extensions
    nix-vscode-extensions = {
      url = "github:nix-community/nix-vscode-extensions";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # nix-inspect - inspect nix derivations usingn a TUI interface
    # https://github.com/bluskript/nix-inspect
    nix-inspect = {
      url = "github:bluskript/nix-inspect";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # talhelper - A tool to help creating Talos kubernetes cluster
    # https://github.com/budimanjojo/talhelper
    talhelper = {
      url = "github:budimanjojo/talhelper";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    # NixVirt for qemu & libvirt
    # https://github.com/AshleyYakeley/NixVirt
    nixvirt-git = {
      url = "github:AshleyYakeley/NixVirt/v0.5.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # vscode-server - NixOS module for running vscode-server
    vscode-server.url = "github:nix-community/nixos-vscode-server";

    # krewfile - Declarative krew plugin management
    # krewfile = {
    #  url = "github:brumhard/krewfile";
    #  inputs.nixpkgs.follows = "nixpkgs";
    # };

    # nix-minecraft - Minecraft server management
    # https://github.com/infinidoge/nix-minecraft
    nix-minecraft = {
      url = "github:Infinidoge/nix-minecraft";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    # Hyprland
    hyprland.url = "github:hyprwm/Hyprland";
    # Hyprland plugins
    hyprland-plugins = {
      url = "github:hyprwm/hyprland-plugins";
      inputs.hyprland.follows = "hyprland";
    };

    # nvf -  A highly modular, extensible and distro-agnostic Neovim configuration framework for Nix/NixOS.
    nvf.url = "github:notashelf/nvf";
  };

  outputs = {
    self,
    nixpkgs,
    nixpkgs-unstable,
    sops-nix,
    home-manager,
    disko,
    lix-module,
    vscode-server,
    nvf,
    ...
  } @ inputs: let
    forAllSystems = nixpkgs.lib.genAttrs [
      "aarch64-linux"
      "x86_64-linux"
    ];
  in rec {
    # Use nixpkgs-fmt for 'nix fmt'
    formatter = forAllSystems (system: nixpkgs.legacyPackages."${system}".nixfmt-rfc-style);

    # setup devshells against shell.nix
    # devShells = forAllSystems (pkgs: import ./shell.nix { inherit pkgs; });

    # extend lib with my custom functions
    lib = nixpkgs.lib.extend (
      final: prev: {
        inherit inputs;
        myLib = import ./nixos/lib {
          inherit inputs;
          lib = final;
        };
      }
    );

    nixosConfigurations = let
      inherit inputs;
      # Import overlays for building nixosconfig with them.
      overlays = import ./nixos/overlays {inherit inputs;};
      # generate a base nixos configuration with the specified overlays, hardware modules, and any AerModules applied
      mkNixosConfig = {
        hostname,
        system ? "x86_64-linux",
        nixpkgs ? inputs.nixpkgs,
        disabledModules ? [],
        hardwareModules ? [],
        # basemodules is the base of the entire machine building
        # here we import all the modules and setup home-manager
        baseModules ? [
          sops-nix.nixosModules.sops
          home-manager.nixosModules.home-manager
          nvf.nixosModules.default
          ./nixos/profiles/global.nix # all machines get a global profile
          ./nixos/modules/nixos # all machines get nixos modules
          ./nixos/hosts/${hostname} # load this host's config folder for machine-specific config
          {
            inherit disabledModules;
            home-manager = {
              useUserPackages = true;
              useGlobalPkgs = true;
              extraSpecialArgs = {
                inherit inputs hostname system;
              };
            };
          }
        ],
        profileModules ? [],
      }:
        nixpkgs.lib.nixosSystem {
          inherit system lib;
          modules = baseModules ++ hardwareModules ++ profileModules;
          specialArgs = {inherit self inputs nixpkgs;};
          # Add our overlays
          pkgs = import nixpkgs {
            inherit system;
            overlays = builtins.attrValues overlays;
            config = {
              allowUnfree = true;
              allowUnfreePredicate = _: true;
            };
          };
        };
    in {
      "shadowfax" = mkNixosConfig {
        # Pro WS WRX80E-SAGE SE WIFI - AMD Ryzen Threadripper PRO 3955WX 16-Cores
        # Workloads server
        hostname = "shadowfax";
        system = "x86_64-linux";
        disabledModules = [
          "services/web-servers/minio.nix"
          "services/web-servers/caddy/default.nix"
        ];
        hardwareModules = [
          lix-module.nixosModules.default
          ./nixos/profiles/hw-threadripperpro.nix
        ];
        profileModules = [
          vscode-server.nixosModules.default
          "${nixpkgs-unstable}/nixos/modules/services/web-servers/minio.nix"
          "${nixpkgs-unstable}/nixos/modules/services/web-servers/caddy/default.nix"
          ./nixos/profiles/role-dev.nix
          ./nixos/profiles/role-server.nix
          {home-manager.users.jahanson = ./nixos/home/jahanson/sworkstation.nix;}
        ];
      };

      "telperion" = mkNixosConfig {
        # HP-S01 Intel G5900
        # Network services server
        hostname = "telperion";
        system = "x86_64-linux";
        hardwareModules = [
          ./nixos/profiles/hw-hp-s01.nix
          disko.nixosModules.disko
          (import ./nixos/profiles/disko-nixos.nix {disks = ["/dev/nvme0n1"];})
        ];
        profileModules = [
          ./nixos/profiles/role-server.nix
          {home-manager.users.jahanson = ./nixos/home/jahanson/server.nix;}
        ];
      };

      "varda" = mkNixosConfig {
        # Arm64 cax21 @ Hetzner
        # forgejo server
        hostname = "varda";
        system = "aarch64-linux";
        hardwareModules = [
          ./nixos/profiles/hw-hetzner-cax.nix
        ];
        profileModules = [
          ./nixos/profiles/role-server.nix
          {home-manager.users.jahanson = ./nixos/home/jahanson/server.nix;}
        ];
      };
    };

    # Convenience output that aggregates the outputs for home, nixos.
    # Also used in ci to build targets generally.
    top = let
      nixtop = nixpkgs.lib.genAttrs (builtins.attrNames inputs.self.nixosConfigurations) (
        attr: inputs.self.nixosConfigurations.${attr}.config.system.build.toplevel
      );
    in
      nixtop;
  };
}
