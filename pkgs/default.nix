{ pkgs, ...}:
with pkgs;
{
  # pkgs = pkgs;
  # fcitx5-qt = pkgs.libsForQt5.callPackage ./fcitx5/fcitx5-qt.nix {};
  # qv2ray-full = import ./v2ray {inherit pkgs lib;};
  wechat-uos = pkgs.callPackage ./wechat-uos { };
  bluelock = pkgs.callPackage ./bluelock { };
  spotbugs = pkgs.callPackage ./spotbugs { };
  "@colbymchenry/codegraph" = pkgs.callPackage ./codegraph { };
  x3-ui = pkgs.callPackage ./3x-ui { };
}
