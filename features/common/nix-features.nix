{ config, pkgs, ... }:

{
  nix = {
    package = pkgs.nixFlakes;
    extraOptions =
      ''
        experimental-features = nix-command flakes
      '';
    gc = {
      automatic = true;
      options = "--delete-older-than 15d";
    };
   };
  nixpkgs.config.allowUnfree = true;
  # nixpkgs.config.allowBroken = true;
}
