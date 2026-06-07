# VPS 最小化：disko 分区 + 原生网络/SSH（无 emodules / home-manager）
{ disko, ... }:

{
  imports = [
    disko.nixosModules.disko
    ./disko.nix
    ./configuration.nix
    ./modules.nix
  ];
}
