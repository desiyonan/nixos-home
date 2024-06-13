{ config, pkgs, ... }:

{
  nix = {
    gc = {
      automatic = true;
      options = "--delete-older-than 7d";
    };
    settings = {
      substituters = [
        "https://mirrors.ustc.edu.cn/nix-channels/store"
        "https://mirror.sjtu.edu.cn/nix-channels/store"
        "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store"
      ];
      experimental-features = [ "nix-command" "flakes" ];
    };
    # registry.nixpkgs.flake = nixpkgs;
  };

  nixpkgs.config = {
    allowUnfree = true;
  };
  # nixpkgs.config.allowBroken = true;
}
