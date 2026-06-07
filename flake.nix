{
  description = "DnF's NixOS configuration";

  inputs = {
    # https://status.nixos.org/
    # track unstable channel for system packages/modules
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    # nixos-cn = {
    #   url = "github:nixos-cn/flakes";
    #   # 强制 nixos-cn 和该 flake 使用相同版本的 base_pkgs
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };

    home-manager = {
      # keep HM aligned with unstable nixpkgs
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix.url = "github:Mic92/sops-nix";
    # with secrets by base on sops-nix;
    secret-hub = {
      # 子模块 secrets/ → github.com/desiyonan/secret-hub
      url = "git+ssh://git@github.com/desiyonan/secret-hub.git";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-anywhere = {
      url = "github:nix-community/nixos-anywhere";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-images = {
      url = "github:nix-community/nixos-images";
      inputs.nixos-unstable.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, ... }@inputs:
    let
      flakeArgs = inputs // { inherit self nixpkgs; };
      lib = import ./lib flakeArgs;
      mesh = import ./mesh (flakeArgs // { inherit lib; });
    in
    with lib;
    rec {
      inherit lib;
      nixosConfigurations = mesh.hosts;
    };
}
