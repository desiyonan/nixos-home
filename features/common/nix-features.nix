{ config, pkgs, ... }:

{
  nix = {
    # binaryCaches = [
    # "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store"
    # "https://mirrors.ustc.edu.cn/nix-channels/store"
    # "https://cache.nixos.org/"
    # ];
    # extraOptions =
    # ''
    #   experimental-features = nix-command flakes
    # '';
    # package = pkgs.nixVersions.stable;
    gc = {
      automatic = true;
      options = "--delete-older-than 7d";
    };
    settings = {
      substituters = [
        "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store"
        "https://mirrors.ustc.edu.cn/nix-channels/store"
      ];
      experimental-features = [ "nix-command" "flakes" ];
    };
  };

  nixpkgs.config = {
    permittedInsecurePackages = [
      "qtwebkit-5.212.0-alpha4"
    ];

    allowUnfree = true;
  };
  # nixpkgs.config.allowBroken = true;
}
