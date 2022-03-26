{
  description = "DnF's NixOS configuration";

  inputs = {
    # To update nixpkgs (and thus NixOS), pick the nixos-unstable rev from
    # https://status.nixos.org/
    #
    # This ensures that we always use the official # cache.
    nixpkgs.url = "github:nixos/nixpkgs/48d63e924a26";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, home-manager, nixpkgs, ... }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
        overlays = [];
      };
      dotfiles = pkgs.callPackage ./dotfiles {};
      mpkgs = pkgs.callPackage ./pkgs { inherit dotfiles;};

      mkHomeMachine = configurationNix: extraModules: sharedModules: nixpkgs.lib.nixosSystem {
        inherit system;
        inherit (self.packages.x86_64-linux) pkgs ;

        # Arguments to pass to all modules.
        specialArgs = { inherit pkgs mpkgs dotfiles; };
        modules = ([
          # System configuration
          configurationNix

          # Features common to all of my machines
          ./features/users/dnf.nix
          ./features/common

          # home-manager configuration
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.dnf = import ./home.nix {
              inherit inputs system;
              pkgs = import nixpkgs { inherit system; };
            };
            home-manager.sharedModules = ([

              ./home-manager
            ] ++ sharedModules);
          }
        ] ++ extraModules);
      };

      mkOnlyHostConfig = configurationNix: mkHomeMachine configurationNix [] [];
      withExtraModules = configurationNix: extraModules:  mkHomeMachine configurationNix extraModules [];
      withSharedModule = configurationNix: sharedModules: mkHomeMachine configurationNix [] sharedModules;
    in
    {
      packages = nixpkgs.lib.genAttrs nixpkgs.lib.platforms.all  (system:
        dotfiles.override
        {
          pkgs = pkgs // removeAttrs self.packages.${system} [ "profiles" "pkgs" ];
        }
      );
      nixosConfigurations.wl = withExtraModules
        ./hosts/wl.nix
        [
          ./pkgs/v2ray.nix
        ];
      nixosConfigurations.ws = withExtraModules
        ./hosts/ws.nix
        [
          ./pkgs/nvidia-offload.nix
          ./pkgs/v2ray.nix
        ];
    };
}
