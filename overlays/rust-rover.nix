{system ? builtins.currentSystem, ...}:

final: prev:
let
  unstable = import <nixos-unstable> { config = { allowUnfree = true; }; };
  unstable_pkgs = import unstable {
    inherit system;
    config.allowUnfree = true;
  };
in
{
  jetbrains = prev.jetbrains // {
    rust-rover = unstable_pkgs.jetbrains.rust-rover;
  };
}
