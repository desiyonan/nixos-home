{
  description = "DnF's NixOS configuration";

  inputs = {
    # https://status.nixos.org/
    # nixpkgs.url = "github:nixos/nixpkgs/ba187fbdc5e3";
    nixpkgs.url = "github:nixos/nixpkgs/5528350186a9";
    # home-manager = {
      # url = "github:nix-community/home-manager";
      # inputs.nixpkgs.follows = "nixpkgs";
    # };
    # nixos-cn = {};
    # nixos-cn = {
    #   # url = "github:nixos-cn/flakes";
    #   url = "github:nixos-cn/flakes/0bd347e7b01c590b9adb602847587bb2d5216bbc";
    #   # 强制 nixos-cn 和该 flake 使用相同版本的 nixpkgs
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };

  };

  outputs = { self, nixpkgs, ... }@inputs:
    let
      inherit (nixpkgs) lib;
      nixos-cn = {};
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
        inherit system pkgs lib mpkgs nixpkgs dotfiles nixos-cn;
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
        wl = utils.host.mkHost hosts.wl defaultUsers;
        ws = utils.host.mkHost hosts.ws defaultUsers;
      };

    };
}
