{nixpkgs, ...}:

final: prev:
{
  mesh = import ../mesh {
    inherit nixpkgs;
    pkgs = prev;
    lib = prev.lib;
  };
}
