{ pkgs, callPackage, ...}:

{
  pkgs = pkgs ;
  latte-dock = pkgs.callPackage ./latte-dock {};
}
