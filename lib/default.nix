{ system, pkgs, lib, mpkgs, home-manager,...}:
rec
{
  user = import ./user.nix { inherit system pkgs lib home-manager;};
  host = import ./host.nix { inherit system pkgs lib user mpkgs;};
}
