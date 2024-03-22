{ pkgs, ...}:
with pkgs;
{
  # pkgs = pkgs;
  # fcitx5-qt = pkgs.libsForQt5.callPackage ./fcitx5/fcitx5-qt.nix {};
  qv2ray-full = import ./v2ray {inherit pkgs lib;};
}
