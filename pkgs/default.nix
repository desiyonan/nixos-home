{ pkgs, callPackage, dotfiles, ...}:
with pkgs;
{
  pkgs = pkgs;
  idea-ultimate = pkgs.callPackage ./idea-ultimate.nix {};
  latte-dock = callPackage ./latte-dock.nix { inherit dotfiles;};
}
