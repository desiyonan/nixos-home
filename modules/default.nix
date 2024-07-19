{pkgs, lib, ...}:
{
  imports = lib.listModules ./.;
}
