{root_inputs, ...}:

final: _prev:
let
  nixpkgs-unstable = root_inputs.nixpkgs-unstable;
in
{
  unstable = import nixpkgs-unstable {
    inherit (final) system config;
  };
}
