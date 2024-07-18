{inputs, ...}:

final: _prev:
let
  nixpkgs-unstable = inputs.nixpkgs-unstable;
in
{
  unstable = import nixpkgs-unstable {
    inherit (final) system config;
  };
}
