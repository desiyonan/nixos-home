{ pkgs, ... }:
{
  imports = [
    ./fonts.nix
    ./git.nix
    ./hardware.nix
    ./nixpkgs-config.nix
  ];
}
