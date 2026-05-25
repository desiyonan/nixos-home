{ nixpkgs-unstable, ... }:

final: _prev:
let
  inherit nixpkgs-unstable;
in
{
  unstable = import nixpkgs-unstable {
    inherit (final) system config;
  };
}
