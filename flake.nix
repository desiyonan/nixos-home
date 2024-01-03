{
  description = "DnF's NixOS configuration";

  inputs = {
    # https://status.nixos.org/
    # the pre pinned version
    prev_pkgs.url = "github:nixos/nixpkgs/5528350186a9"; #22.11
    # the current pinned base version
    base_pkgs.url = "github:nixos/nixpkgs/7f7851dfc570"; #23.11
    # the current roll version
    roll_pkgs.url = "github:nixos/nixpkgs/nixos-23.11"; #23.11 lastest
    unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nixos-cn = {
      # url = "github:nixos-cn/flakes";
      url = "github:nixos-cn/flakes/0bd347e7b01c590b9adb602847587bb2d5216bbc";
      # 强制 nixos-cn 和该 flake 使用相同版本的 base_pkgs
      inputs.nixpkgs.follows = "base_pkgs";
    };
  };

  outputs = { self, prev_pkgs, base_pkgs, roll_pkgs, unstable, ... }@inputs:
    let
      system = "x86_64-linux";
      nixpkgs = base_pkgs;
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
        overlays = (import ./overlays (inputs // {
          inherit nixpkgs;
        }));
      };
    in
    with pkgs.mesh;
    {
      nixosConfigurations = {
        wl = mlibs.host.mkHost hosts.wl defaultUsers;
        ws = mlibs.host.mkHost hosts.ws defaultUsers;
      };
    };
}
