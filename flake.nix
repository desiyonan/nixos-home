{
  description = "DnF's NixOS configuration";

  inputs = {
    # https://status.nixos.org/
    nixpkgs.url = "github:nixos/nixpkgs/ff9efb0724de";
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
    in
    {

      nixosConfigurations = {
        wl = utils.host.mkHost  hosts.wl defaultUsers;
        ws = utils.host.mkHost (hosts.ws // {
            services = {
                nvidia-offload.enable = true;
            };
        }) defaultUsers;
      };

    };
}
