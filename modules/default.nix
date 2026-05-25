{ lib, nixpkgs, ... }@args:
{
  imports = lib.listModules ./.;
  _module.args = args;
}
