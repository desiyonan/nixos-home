{ system, pkgs, lib, mpkgs, nixpkgs, dotfiles, nixos-cn, ...}:
rec
{
  # user = import ./user.nix { inherit system pkgs lib home-manager;};
  user = import ./user.nix { inherit system pkgs lib ;};
  host = import ./host.nix { inherit system pkgs lib user mpkgs nixpkgs dotfiles nixos-cn ;};
}
