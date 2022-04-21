{ pkgs, dotfiles, nixos-cn, ...}:
with pkgs;
{
  pkgs = pkgs;
  idea-ultimate = pkgs.callPackage ./idea-ultimate.nix {};
  latte-dock =   pkgs.callPackage  ./latte-dock.nix { inherit dotfiles;};
  qv2ray-full = import ./v2ray.nix {inherit pkgs lib dotfiles;};
  nvidia-offload = import ./nvidia-offload.nix {inherit pkgs;};
} // nixos-cn.legacyPackages.${system}
