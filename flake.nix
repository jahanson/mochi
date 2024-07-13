{
  description = "My NixOS flake";

  inputs = {
    # Nixpkgs and unstable
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    # impermanence
    # https://github.com/nix-community/impermanence
    impermanence.url = "github:nix-community/impermanence";

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
      url = "github:nix-community/home-manager/release-24.05";
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

    # nix-index database
    # https://github.com/nix-community/nix-index-database
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # nix-inspect - inspect nix derivations usingn a TUI interface
    # https://github.com/bluskript/nix-inspect
    nix-inspect = {
      url = "github:bluskript/nix-inspect";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # talhelper - A tool to help creating Talos kubernetes cluster
    talhelper = {
      url = "github:budimanjojo/talhelper";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Lix- Substitution of the Nix package manager, focused on correctness, usability, and growth – and committed to doing right by its community.
    # https://git.lix.systems/lix-project/lix
    lix-module = {
      url = "https://git.lix.systems/lix-project/nixos-module/archive/2.90.0.tar.gz";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # NixVirt for qemu & libvirt
    # https://github.com/AshleyYakeley/NixVirt
    nixvirt-git = {
      url = "github:AshleyYakeley/NixVirt/v0.5.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };

  };

  outputs =
    { self, nixpkgs, sops-nix, home-manager, nix-vscode-extensions, impermanence, disko, talhelper, lix-module, ... } @ inputs:
    let
      forAllSystems = nixpkgs.lib.genAttrs [
        "aarch64-linux"
        "x86_64-linux"
      ];
    in
    rec {
      # Use nixpkgs-fmt for 'nix fmt'
      formatter = forAllSystems (system: nixpkgs.legacyPackages."${system}".nixpkgs-fmt);

      # setup devshells against shell.nix
      # devShells = forAllSystems (pkgs: import ./shell.nix { inherit pkgs; });

      # extend lib with my custom functions
      lib = nixpkgs.lib.extend (
        final: prev: {
          inherit inputs;
          myLib = import ./nixos/lib { inherit inputs; lib = final; };
        }
      );

      nixosConfigurations =
        let
          inherit inputs;
          # Import overlays for building nixosconfig with them.
          overlays = import ./nixos/overlays { inherit inputs; };
          # generate a base nixos configuration with the specified overlays, hardware modules, and any AerModules applied
          mkNixosConfig =
            { hostname
            , system ? "x86_64-linux"
            , nixpkgs ? inputs.nixpkgs
            , hardwareModules ? [ ]
              # basemodules is the base of the entire machine building
              # here we import all the modules and setup home-manager
            , baseModules ? [
                sops-nix.nixosModules.sops
                home-manager.nixosModules.home-manager
                impermanence.nixosModules.impermanence
                ./nixos/profiles/global.nix # all machines get a global profile
                ./nixos/modules/nixos # all machines get nixos modules
                ./nixos/hosts/${hostname}   # load this host's config folder for machine-specific config
                {
                  home-manager = {
                    useUserPackages = true;
                    useGlobalPkgs = true;
                    extraSpecialArgs = {
                      inherit inputs hostname system;
                    };
                  };
                }
              ]
            , profileModules ? [ ]
            }:
            nixpkgs.lib.nixosSystem {
              inherit system lib;
              modules = baseModules ++ hardwareModules ++ profileModules;
              specialArgs = { inherit self inputs nixpkgs; };
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
        in
        {
          "durincore" = mkNixosConfig {
            # T470 Thinkpad Intel i7-6600U
            # Nix dev laptop
            hostname = "durincore";
            system = "x86_64-linux";
            hardwareModules = [
              ./nixos/profiles/hw-thinkpad-t470.nix
              inputs.nixos-hardware.nixosModules.lenovo-thinkpad-t470s
            ];
            profileModules = [
              ./nixos/profiles/role-workstation.nix
              ./nixos/profiles/role-dev.nix
              { home-manager.users.jahanson = ./nixos/home/jahanson/workstation.nix; }
            ];
          };

          "legiondary" = mkNixosConfig {
            # Legion 15arh05h AMD/Nvidia Ryzen 7 4800H
            # Nix dev/gaming laptop
            hostname = "legiondary";
            system = "x86_64-linux";
            hardwareModules = [
              inputs.nixos-hardware.nixosModules.lenovo-legion-15arh05h
              ./nixos/profiles/hw-legion-15arh05h.nix
              disko.nixosModules.disko
              (import ./nixos/profiles/disko-nixos.nix { disks = [ "/dev/nvme0n1" ]; })
            ];
            profileModules = [
              ./nixos/profiles/role-dev.nix
              ./nixos/profiles/role-gaming.nix
              ./nixos/profiles/role-workstation.nix
              { home-manager.users.jahanson = ./nixos/home/jahanson/workstation.nix; }
            ];
          };

          "telchar" = mkNixosConfig {
            # Framework 16 Ryzen 7 7840HS - Radeon 780M Graphics
            # Nix dev laptop
            hostname = "telchar";
            system = "x86_64-linux";
            hardwareModules = [
              inputs.nixos-hardware.nixosModules.framework-16-7040-amd
              ./nixos/profiles/hw-framework-16-7840hs.nix
              disko.nixosModules.disko
              (import ./nixos/profiles/disko-nixos.nix { disks = [ "/dev/nvme0n1" ]; })
              lix-module.nixosModules.default
            ];
            profileModules = [
              ./nixos/profiles/role-dev.nix
              ./nixos/profiles/role-workstation.nix
              { home-manager.users.jahanson = ./nixos/home/jahanson/workstation.nix; }
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
              { home-manager.users.jahanson = ./nixos/home/jahanson/server.nix; }
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
              (import ./nixos/profiles/disko-nixos.nix { disks = [ "/dev/nvme0n1" ]; })

            ];
            profileModules = [
              ./nixos/profiles/role-server.nix
              { home-manager.users.jahanson = ./nixos/home/jahanson/server.nix; }
            ];
          };

          "gandalf" = mkNixosConfig {
            # X9DRi-LN4+/X9DR3-LN4+ - Intel(R) Xeon(R) CPU E5-2650 v2
            # NAS
            hostname = "gandalf";
            system = "x86_64-linux";
            hardwareModules = [
              # lix-module.nixosModules.default
              ./nixos/profiles/hw-supermicro.nix
              disko.nixosModules.disko
              (import ./nixos/profiles/disko-nixos.nix { disks = [ "/dev/sda/dev/disk/by-id/ata-Seagate_IronWolfPro_ZA240NX10001-2ZH100_7TF002RA" ]; })
            ];
            profileModules = [
              ./nixos/profiles/role-server.nix
              { home-manager.users.jahanson = ./nixos/home/jahanson/server.nix; }
            ];
          };
        };

      # Convenience output that aggregates the outputs for home, nixos.
      # Also used in ci to build targets generally.
      top =
        let
          nixtop = nixpkgs.lib.genAttrs
            (builtins.attrNames inputs.self.nixosConfigurations)
            (attr: inputs.self.nixosConfigurations.${attr}.config.system.build.toplevel);
        in
        nixtop;
    };
}
