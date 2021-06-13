{
  description = "DnF's NixOS configuration";

  inputs = {
    # To update nixpkgs (and thus NixOS), pick the nixos-unstable rev from
    # https://status.nixos.org/
    # 
    # This ensures that we always use the official # cache.
    nixpkgs.url = "github:nixos/nixpkgs/432fc2d9a67f92e05438dff5fdc2b39d33f77997";
    home-manager.url = "github:nix-community/home-manager";
  };

  outputs = inputs@{ self, home-manager, nixpkgs, ... }:
    let
      system = "x86_64-linux";
      
      mkHomeMachine = configurationNix: extraModules: nixpkgs.lib.nixosSystem {
        inherit system;

        # Arguments to pass to all modules.
        specialArgs = { inherit system inputs; };
        modules = ([
          # System configuration
          configurationNix

          # Features common to all of my machines
          #   ./features/self-ide.nix
          # ./features/caches
          #   ./features/current-location.nix
          # ./features/passwordstore.nix
          # ./features/v2ray.nix
          # ./features/zerotierone.nix
          #   ./features/syncthing.nix
          #   ./features/protonvpn.nix
          #   ./features/monitor-brightness.nix

          # home-manager configuration
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.dnf = import ./home.nix {
              inherit inputs system;
              pkgs = import nixpkgs { inherit system; };
            };
          }
        ] ++ extraModules);
      };
    in
    {
      nixosConfigurations.wl = mkHomeMachine
        ./hosts/wl.nix
        [
          # ./features/plasma5.nix
          ./features/users/dnf.nix
        ];
    };
}