{
  description = "iLikeToCode's NixOS config";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";

    webots.url = "https://github.com/cyberbotics/webots/releases/download/R2025a/webots-R2025a-x86-64.tar.bz2";
    webots.flake = false;
  };
  outputs =
    { self, nixpkgs, home-manager, flake-utils, webots, ... }@attrs:
    let
      eachSystem = nixpkgs.lib.genAttrs [ "x86_64-linux" "aarch64-linux" ];

      nixosConfigsForSystem = system:
        nixpkgs.lib.mapAttrs
          (_: cfg: cfg.config.system.build.toplevel)
          (nixpkgs.lib.filterAttrs
            (_: cfg: cfg.pkgs.stdenv.hostPlatform.system == system)
            self.nixosConfigurations);

      nixpkgsFor = system: let
          pkgs = import nixpkgs { inherit system; };

          patchFiles =
            map (name: ./patches + "/${name}")
              (builtins.attrNames
                (pkgs.lib.filterAttrs (_: v: v == "regular")
                  (builtins.readDir ./patches)));

          patchedPkgs = pkgs.applyPatches {
            name = "nixpkgs-patched-${nixpkgs.shortRev}";
            src = nixpkgs;
            patches = patchFiles;
          };
        in import patchedPkgs { inherit system; };
    in
    {
      nixosConfigurations = {
        ah-w = nixpkgs.lib.nixosSystem rec {
          system = "x86_64-linux";
          specialArgs = attrs;
          modules = [
            ./machines/AH-W.nix
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = false;
              home-manager.users.archie = ./home-manager/archie.nix;
            }
          ];
        };
        ah-l = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = attrs;
          modules = [
            ./machines/AH-L.nix
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = false;
              home-manager.users.archie = ./home-manager/archie.nix;
            }
          ];
        };
        ah-hpl = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = attrs;
          modules = [
            ./machines/AH-HPL.nix
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = false;
              home-manager.users.archie = ./home-manager/archie.nix;
            }
          ];
        };
        olp-ml04 = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = attrs;
          modules = [
            ./machines/OLP-ML04.nix
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = false;
              home-manager.users.archie = ./home-manager/archie.nix;
            }
          ];
        };
        hydra = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = attrs;
          modules = [
            ./machines/hydra.nix
          ];
        };
        hydra-disklabel-hydra = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = attrs;
          modules = [
            ./machines/hydra-disklabel-hydra.nix
          ];
        };
        iso = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = attrs;
          modules = [
            "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-base.nix"
            ./machines/iso.nix
          ];
        };
      };
      
      legacyPackages = eachSystem (system:
        import ./. {
          pkgs = import nixpkgs {
            inherit system;
          };
          lib = nixpkgs.lib;
          flat = false;
          inherit attrs;
        }
      );

      packages = eachSystem (system:
        import ./. {
          pkgs = import nixpkgs {
            inherit system;
          };
          lib = nixpkgs.lib;
          flat = true;
          inherit attrs;
        }
      );

      hydraJobs = {
        packages = self.packages;
        configs = eachSystem (system:
          nixosConfigsForSystem system
        );
        images = eachSystem (system:
          let
            pkgs = nixpkgs.legacyPackages.${system};
            lib = pkgs.lib;
          in
          lib.optionalAttrs (system == "x86_64-linux") {
            iso = self.nixosConfigurations.iso.config.system.build.isoImage;
          }
        );
      };
    };
}
