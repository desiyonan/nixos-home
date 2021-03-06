{ pkgs, dotfiles, nixos-cn, ...}:
with pkgs;
{
  pkgs = pkgs;
  idea-ultimate = pkgs.callPackage ./idea-ultimate.nix {};
  # fcitx5-qt = pkgs.libsForQt5.callPackage ./fcitx5/fcitx5-qt.nix {};
  latte-dock =   pkgs.callPackage  ./latte-dock.nix { inherit dotfiles;};
  qv2ray-full = import ./v2ray.nix {inherit pkgs lib dotfiles;};
  nvidia-offload = import ./nvidia-offload.nix {inherit pkgs;};
} // nixos-cn.legacyPackages.${system}
