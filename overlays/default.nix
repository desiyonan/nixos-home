{ nixpkgs, lib, ... }@args:

{
  nixpkgs.overlays = lib.importModules ./. args;
}
