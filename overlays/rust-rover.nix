{unstable, system, ...}:

final: prev:
let
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
