{nixpkgs, ...}:

final: prev:
{
  mpkgs = import ../pkgs {
    inherit nixpkgs;
    pkgs = prev;
    lib = prev.lib;
  };
}
