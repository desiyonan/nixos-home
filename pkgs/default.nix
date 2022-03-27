{ pkgs, dotfiles, ...}:
with pkgs;
{
  pkgs = pkgs;
  idea-ultimate = pkgs.callPackage ./idea-ultimate.nix {};
  latte-dock = pkgs.callPackage ./latte-dock.nix { inherit dotfiles;};
}
