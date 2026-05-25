{ lib, nixpkgs, self, ... }@flake:
{
  dotfs = import ./dotfs flake;
  hosts = import ./hosts flake;
  users = import ./users flake;
}
