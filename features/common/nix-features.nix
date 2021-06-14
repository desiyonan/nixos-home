{ config, pkgs, ... }:

{
  nix = {
    package = pkgs.nixUnstable;
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
}
