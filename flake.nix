{
  description = "DnF's NixOS configuration";

  inputs = {
    # https://status.nixos.org/
    nixpkgs.url = "github:nixos/nixpkgs/48d63e924a26";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, home-manager, nixpkgs, ... }@inputs:
    let
      inherit (nixpkgs) lib;

      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
        overlays = [];
      };

      dotfiles = import ./dotfiles {inherit pkgs;};
      mpkgs = import ./pkgs {
        inherit dotfiles pkgs ;
      };

      utils = import ./lib {
        inherit system pkgs lib mpkgs home-manager ;
      };
      users = import ./users {inherit pkgs;};
      hosts = import ./hosts ;

      defaultUsers = [users.default];

      inherit (utils) user;
      inherit (utils) host;

      system = "x86_64-linux";

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

      nixosConfigurations = {
        wl = utils.host.mkHost  hosts.wl defaultUsers;
        ws = utils.host.mkHost (hosts.ws // {
            services = {
                services.nvidia-offload.enable = true;
            };
        }) defaultUsers;
      };

    };
}
