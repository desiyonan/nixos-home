{ pkgs, ...}:
with pkgs;
let
  c = callPackage;
in
{
  latte-dock= import ./latte-dock;
  v2ray = import ./v2ray;
}
