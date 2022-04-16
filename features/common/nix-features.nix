{ config, pkgs, ... }:

{
  nix = {
    # binaryCaches = [
    # "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store"
    # "https://mirrors.ustc.edu.cn/nix-channels/store"
    # "https://cache.nixos.org/"
    # ];
    package = pkgs.nixFlakes;
    extraOptions =
      ''
        experimental-features = nix-command flakes
      '';
    gc = {
      automatic = true;
      options = "--delete-older-than 7d";
    };
    settings = {
      substituters = [
        "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store"
        "https://mirrors.ustc.edu.cn/nix-channels/store"
      ];
    };
  };
  nixpkgs.config.allowUnfree = true;
  # nixpkgs.config.allowBroken = true;
}
