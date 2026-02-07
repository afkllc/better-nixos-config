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
    {
      let
        eachSystem = nixpkgs.lib.genAttrs [ "x86_64-linux" "aarch64-linux" ];

        nixosConfigsForSystem = system:
          nixpkgs.lib.mapAttrs
            (_: cfg: cfg.config.system.build.toplevel)
            (nixpkgs.lib.filterAttrs
              (_: cfg: cfg.pkgs.stdenv.hostPlatform.system == system)
              self.nixosConfigurations);
      in
      nixosConfigurations = {
        ah-w = nixpkgs.lib.nixosSystem {
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
      
      packages = {
        "x86_64-linux" = let
          pkgs = import nixpkgs { system = "x86_64-linux"; };
          webotsSrc = webots;

          dependencies = with pkgs; [
            brotli sndio boost cmake curl dbus expat ffmpeg fox freetype
            gdal gl2ps glew glib gnumake gnupg jdk krb5 libGL libGLU
            libgcrypt libssh2 libuuid libxkbcommon libxml2 libzip
            lsb-release nss_latest pbzip2 pkg-config prelink proj
            python311 readline swig unzip wget xercesc
            xorg.libX11 xorg.libXcomposite xorg.libXtst
            xorg.libxcb xorg.xcbutil xvfb-run zip zlib
          ];

          desktopFile = pkgs.makeDesktopItem {
            name = "webots-fhs";
            exec = "%%EXEC%%";
            icon = "${webotsSrc}/resources/icons/core/webots.png";
            comment = "Webots in an FHS environment";
            desktopName = "Webots (FHS)";
            genericName = "Webots (FHS)";
            categories = [ "Utility" ];
          };
        in rec {
          # The actual Webots package
          webots = pkgs.buildFHSEnv {
            name = "webots";
            targetPkgs = pkgs: dependencies;

            runScript = pkgs.writeShellScript "webots" ''
              export QT_PLUGIN_PATH=${webotsSrc}/lib/webots/qt/plugins
              export WEBOTS_HOME=${webotsSrc}
              exec ${webotsSrc}/webots "$@"
            '';

            extraInstallCommands = ''
              mkdir -p $out
              cp -r ${desktopFile}/* $out/
              chmod +w $out/share/applications
              sed -i "s#%%EXEC%%#$out/bin/webots#" \
                $out/share/applications/webots-fhs.desktop
            '';

            meta.description = "Webots in an FHS environment";
          };
        };
      };

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
