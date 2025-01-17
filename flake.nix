{
  description = "DnF's NixOS configuration";

  inputs = {
    # https://status.nixos.org/
    # the current pinned base version
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11"; #24.11
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    nixos-cn = {
      # url = "github:nixos-cn/flakes";
      url = "github:nixos-cn/flakes/0bd347e7b01c590b9adb602847587bb2d5216bbc";
      # 强制 nixos-cn 和该 flake 使用相同版本的 base_pkgs
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      # url = "github:nix-community/home-manager";
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix.url = "github:Mic92/sops-nix";
    # with secrets by base on sops-nix;
    secret-hub = {
      url = "git+ssh://git@github.com/desiyonan/secret-hub.git"; #./secrets
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, home-manager, ... }@inputs:
    let
      mesh = import ./mesh;
      mlib = import ./lib self;
      lib = nixpkgs.lib.extend mlib;
    in
    with lib;
    with mesh;
    {
      inherit lib;
      nixosConfigurations = {
        wl = mkHost hosts.wl users.defaults;
        ws = mkHost hosts.ws users.defaults;
      };
    };
}
