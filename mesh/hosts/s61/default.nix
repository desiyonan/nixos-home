# VPS 最小化：disko 分区 + 原生网络/SSH（nixos-anywhere 整盘安装）
{ disko, ... }:

{
  imports = [
    disko.nixosModules.disko
    ./disko.nix
    ./configuration.nix
    ./modules.nix
    ./memory.nix
    ./3x-ui.nix
    ./headscale.nix
  ];
}
