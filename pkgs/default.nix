{ pkgs, dotfiles, nixos-cn, ...}:
with pkgs;
{
  pkgs = pkgs;
  idea-ultimate = pkgs.callPackage ./idea-ultimate {};
  latte-dock =   pkgs.libsForQt5.callPackage  ./latte-dock { inherit dotfiles;};
  # fcitx5-qt = pkgs.libsForQt5.callPackage ./fcitx5/fcitx5-qt.nix {};
  qv2ray-full = import ./v2ray {inherit pkgs lib dotfiles;};
} // nixos-cn.legacyPackages.${system}
