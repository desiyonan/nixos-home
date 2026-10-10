{ pkgs, ...}:
with pkgs;
{
  wechat-uos = pkgs.callPackage ./wechat-uos { };
  bluelock = pkgs.callPackage ./bluelock { };
  spotbugs = pkgs.callPackage ./spotbugs { };
  "@colbymchenry/codegraph" = pkgs.callPackage ./codegraph { };
  x3-ui = pkgs.callPackage ./3x-ui { };
  sunlogin = pkgs.callPackage ./sunlogin { };
  yunshu = pkgs.callPackage ./yunshu { };
  pinentry-howdy = pkgs.callPackage ./pinentry-howdy { };
}
