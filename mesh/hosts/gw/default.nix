{ mt7927, ... }:

{
  imports = [
    mt7927.nixosModules.default
    ./configuration.nix
    ./modules.nix
    ./memory.nix
    ./router.nix
  ];
}
