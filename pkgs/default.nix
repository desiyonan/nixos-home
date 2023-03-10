{ pkgs, dotfiles, nixos-cn, ...}:
with pkgs;
{
  pkgs = pkgs;
  idea-ultimate = pkgs.callPackage ./idea-ultimate.nix {};
  latte-dock =   pkgs.libsForQt5.callPackage  ./latte-dock { inherit dotfiles;};
  # fcitx5-qt = pkgs.libsForQt5.callPackage ./fcitx5/fcitx5-qt.nix {};
  # qv2ray-full = import ./v2ray.nix {inherit pkgs lib dotfiles;};
  nvidia-offload = import ./nvidia-offload.nix {inherit pkgs;};
} 
# // nixos-cn.legacyPackages.${system}
