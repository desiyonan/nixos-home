{ nixpkgs, lib, inputs, ... }@args:

{
  nixpkgs.overlays = lib.importModules ./. args;
}
