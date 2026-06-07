{ lib, nixpkgs, ... }@args:
let
  overlays = import ../overlays args;
  emodules = import ../modules args;
in
{
  mkHost = hostModules:
    let
      modules = if builtins.isList hostModules then hostModules else [ hostModules ];
    in
    lib.nixosSystem {
      specialArgs = args;
      modules = [
        args.nixpkgs.nixosModules.notDetected
        args.home-manager.nixosModules.default
        args.secret-hub.nixosModules.default
        overlays
        emodules
      ] ++ modules;
    };
}
