{
  description = "DnF's NixOS configuration";

  inputs = {
    # https://status.nixos.org/
    nixpkgs.url = "github:nixos/nixpkgs/ff9efb0724de";
    # nixpkgs.url = "github:nixos/nixpkgs/2f06b87f64bc";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-cn = {
      url = "github:nixos-cn/flakes";
      # 强制 nixos-cn 和该 flake 使用相同版本的 nixpkgs
      inputs.nixpkgs.follows = "nixpkgs";
    };

  };

  outputs = { self, home-manager, nixpkgs, nixos-cn, ... }@inputs:
    let
      inherit (nixpkgs) lib;

      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
        overlays = [];
      };

      dotfiles = import ./dotfiles {inherit pkgs;};
      mpkgs = import ./pkgs {
        inherit dotfiles pkgs nixos-cn;
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
