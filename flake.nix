{
  description = "DnF's NixOS configuration";

  inputs = {
    # https://status.nixos.org/
    # the current pinned base version
    nixpkgs.url = "github:nixos/nixpkgs/7f7851dfc570"; #23.11
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    nixos-cn = {
      # url = "github:nixos-cn/flakes";
      url = "github:nixos-cn/flakes/0bd347e7b01c590b9adb602847587bb2d5216bbc";
      # 强制 nixos-cn 和该 flake 使用相同版本的 base_pkgs
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, ... }@inputs:
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
