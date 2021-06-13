{ pkgs, ... }:

{


  nix.binaryCaches = [
    "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store"
    # "https://mirrors.ustc.edu.cn/nix-channels/store"
    #"https://cache.nixos.org/"
  ];

}