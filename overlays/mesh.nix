{nixpkgs, ...}:

final: prev:
{
  mesh = import ../mesh;
}
