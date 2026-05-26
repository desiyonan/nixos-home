{ nixpkgs-unstable, ... }:

final: _prev:
let
  inherit nixpkgs-unstable;
in
{
  unstable = import nixpkgs-unstable {
    system = final.stdenv.hostPlatform.system;
    inherit (final) config;
  };
}
