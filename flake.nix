{
  description = "DnF's NixOS configuration";

  inputs = {
    # https://status.nixos.org/
    # the current pinned base version
    nixpkgs.url = "github:nixos/nixpkgs/7f7851dfc570"; #23.11
    unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nixos-cn = {
      # url = "github:nixos-cn/flakes";
      url = "github:nixos-cn/flakes/0bd347e7b01c590b9adb602847587bb2d5216bbc";
      # 强制 nixos-cn 和该 flake 使用相同版本的 base_pkgs
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, unstable, ... }@inputs:
    let
      overlays = import ./overlays;
      lib = import ./lib {
        lib = nixpkgs.lib;
      };
      # pkgs = import nixpkgs {
      #   # inherit (stdenv.hostPlatform) system;
      #   inherit system;
      #   config.allowUnfree = true;
      #   overlays =
      #   (import ./overlays (inputs // {
      #     inherit nixpkgs system;
      #   }));
      # };
      mesh = import ./mesh;
    in
    with lib;
    with mesh;
    {
      nixosConfigurations = {
        wl = mkHost hosts.wl users.defaults;
        ws = mkHost hosts.ws users.defaults;
      };
    };
}
