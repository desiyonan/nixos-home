{...}:

final: prev:
{
  jetbrains = prev.jetbrains // {
    rust-rover = final.unstable.jetbrains.rust-rover;
  };
}
