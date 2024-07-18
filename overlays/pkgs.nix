{nixpkgs, ...}:

final: prev:
let
  mpkgs = import ../pkgs {
    inherit nixpkgs;
    pkgs = prev;
    lib = prev.lib;
  };
in
{
  inherit mpkgs;
} // mpkgs
