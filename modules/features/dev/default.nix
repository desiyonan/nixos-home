{ pkgs, lib, ... }:

{
  imports = lib.listModules ./.;

  environment.systemPackages = with pkgs;[
    feishu
  ];
}
